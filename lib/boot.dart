// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:hive/hive.dart';
import 'package:i18n/i18n.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stack_trace/stack_trace.dart';

// Project imports:
import 'boorus/registry.dart';
import 'core/app.dart';
import 'core/boorus/booru/providers.dart';
import 'core/boorus/engine/providers.dart';
import 'core/cache/providers.dart';
import 'core/configs/config.dart';
import 'core/configs/config/data.dart';
import 'core/configs/manage/providers.dart';
import 'core/http/http.dart';
import 'core/http/providers.dart';
import 'core/settings/providers.dart';
import 'core/settings/settings.dart';
import 'core/tags/configs/providers.dart';
import 'core/widgets/widgets.dart';
import 'foundation/app_rating/src/providers.dart';
import 'foundation/app_update/providers.dart';
import 'foundation/boot.dart';
import 'foundation/boot/providers.dart';
import 'foundation/iap/iap.dart';
import 'foundation/info/app_info.dart';
import 'foundation/info/device_info.dart';
import 'foundation/info/package_info.dart';
import 'foundation/loggers.dart';
import 'foundation/mobile.dart';
import 'foundation/path.dart';
import 'foundation/platform.dart';
import 'foundation/utils/file_utils.dart';
import 'foundation/vendors/google/providers.dart';
import 'foundation/windows.dart' as window;

Future<void> boot(BootData bootData) async {
  final logger = bootData.logger;
  final appLogger = bootData.appLogger;

  final stopwatch = Stopwatch()..start();
  logger.info('Start up', 'App Start up');

  logger.debugBoot('Initialize MediaKit');
  MediaKit.ensureInitialized();

  if (isDesktopPlatform()) {
    await window.initialize();
  }

  logger.debugBoot("Load database's directory");
  final dbDirectory = await _initDbDirectory();

  logger.debugBoot('Initialize Hive');
  Hive.init(dbDirectory.path);

  logger.debugBoot('Load app info');
  final appInfo = await getAppInfo();

  final booruRegistry = createBooruRegistry();

  logger.debugBoot('Load boorus from assets');
  final boorus = await loadBoorusFromAssets(booruRegistry);

  logger.debugBoot('Initialize settings repository');
  final settingRepository = await createSettingsRepo(logger: logger);

  logger.debugBoot('Set certificate to trusted certificates');
  await _initCert();

  final booruUserRepo = await createBooruConfigsRepo(
    logger: logger,
    onCreateNew: !bootData.isFossBuild
        ? (id) async {
            final settings = await settingRepository.load().run().then(
              (value) => value.fold(
                (l) => Settings.defaultSettings,
                (r) => r,
              ),
            );

            logger.debugBoot('Save default booru config');
            await settingRepository.save(
              settings.copyWith(currentBooruConfigId: id),
            );
          }
        // Skip creating default config in FOSS build
        : null,
  );

  logger.debugBoot('Load settings');
  final settings = await settingRepository.load().run().then(
    (value) => value.fold(
      (l) => Settings.defaultSettings,
      (r) => r,
    ),
  );

  fvp.registerWith(
    options: {
      'platforms': [
        'linux',
        'ios',
        'windows',
        'macos',
        if (settings.videoPlayerEngine == VideoPlayerEngine.mdk) 'android',
      ],
    },
  );

  logger
    ..debugBoot('Settings: ${settings.toJson()}')
    ..debugBoot('Load current booru config');
  final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(settings);

  logger.debugBoot('Load all configs');
  final allConfigs = await booruUserRepo.getAll();

  final tempPath = await getAppTemporaryDirectory();

  logger.debugBoot('Initialize misc data box');
  final miscDataBox = await Hive.openBox<String>(
    'misc_data_v1',
    path: tempPath.path,
  );

  logger.debugBoot('Initialize package info');
  final packageInfo = await PackageInfo.fromPlatform();

  final tagInfoOverride = await createTagInfoOverride(
    logger: logger,
  );

  logger.debugBoot('Initialize device info');
  final deviceInfo = await DeviceInfoService(
    plugin: DeviceInfoPlugin(),
  ).getDeviceInfo();

  logger.debugBoot('Initialize i18n');
  await ensureI18nInitialized(settings.language);

  FlutterError.demangleStackTrace = (stack) {
    if (stack is Trace) return stack.vmTrace;
    if (stack is Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  if (settings.clearImageCacheOnStartup) {
    logger
      ..info('Start up', 'Clearing image cache on startup')
      ..debugBoot('Clear image cache');
    await clearImageCache();
  }

  HttpOverrides.global = AppHttpOverrides();

  // Prepare for Android 15
  unawaited(showSystemStatus());

  logger.info(
    'Start up',
    'Initialization done in ${stopwatch.elapsed.inMilliseconds}ms',
  );
  stopwatch.stop();

  logger.debugBoot('Run app');
  appLogger
    ..clearLogsAtOrBelow(LogLevel.verbose)
    ..updateLevel(LogLevel.info);

  runApp(
    Reboot(
      initialData: RebootData(
        config: initialConfig ?? BooruConfig.empty,
        configs: allConfigs,
        settings: settings,
      ),
      builder: (context, data, key) => BooruLocalization(
        child: ProviderScope(
          key: key,
          overrides: [
            booruEngineRegistryProvider.overrideWith(
              (ref) => ref.watch(
                booruInitEngineProvider(
                  (db: boorus, registry: booruRegistry),
                ),
              ),
            ),
            appRatingProvider.overrideWithValue(bootData.appRatingService),
            iapFuncProvider.overrideWithValue(bootData.iapFunc),
            isFossBuildProvider.overrideWithValue(bootData.isFossBuild),
            if (bootData.appUpdateChecker case final AppUpdateBuilder builder)
              appUpdateCheckerProvider.overrideWith(
                (_) => builder(packageInfo),
              ),
            booruDbProvider.overrideWithValue(boorus),
            tagInfoOverride,
            settingsRepoProvider.overrideWithValue(settingRepository),
            settingsNotifierProvider.overrideWith(
              () => SettingsNotifier(data.settings),
            ),
            initialSettingsProvider.overrideWithValue(data.settings),
            booruConfigRepoProvider.overrideWithValue(booruUserRepo),
            booruConfigProvider.overrideWith(
              () => BooruConfigNotifier(
                initialConfigs: data.configs,
              ),
            ),
            initialSettingsBooruConfigProvider.overrideWithValue(data.config),
            httpCacheDirProvider.overrideWithValue(tempPath),
            loggerProvider.overrideWithValue(logger),
            deviceInfoProvider.overrideWithValue(deviceInfo),
            packageInfoProvider.overrideWithValue(packageInfo),
            appInfoProvider.overrideWithValue(appInfo),
            appLoggerProvider.overrideWithValue(appLogger),
            miscDataBoxProvider.overrideWithValue(miscDataBox),
            isGooglePlayServiceAvailableProvider.overrideWithValue(
              bootData.googleApiAvailable,
            ),
          ],
          child: const App(),
        ),
      ),
    ),
  );
}

Future<Directory> _initDbDirectory() async {
  return isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();
}

Future<void> _initCert() async {
  try {
    // https://stackoverflow.com/questions/69511057/flutter-on-android-7-certificate-verify-failed-with-letsencrypt-ssl-cert-after-s
    // On Android 7 and below, the Let's Encrypt certificate is not trusted by default and needs to be added manually.
    final cert = await rootBundle.load('assets/ca/isrgrootx1.pem');

    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      cert.buffer.asUint8List(),
    );
  } catch (e) {
    // ignore errors here, maybe it's already trusted
  }
}

final dbPathProvider = FutureProvider<String>((ref) async {
  final dbDirectory = await _initDbDirectory();

  return dbDirectory.path;
});
