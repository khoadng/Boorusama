// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stack_trace/stack_trace.dart';

// Project imports:
import 'boorus/providers.dart';
import 'core/app.dart';
import 'core/bookmarks/providers.dart';
import 'core/boorus/booru/booru.dart';
import 'core/boorus/booru/providers.dart';
import 'core/boorus/engine/providers.dart';
import 'core/cache/providers.dart';
import 'core/configs/config.dart';
import 'core/configs/current.dart';
import 'core/configs/manage.dart';
import 'core/foundation/loggers.dart';
import 'core/foundation/mobile.dart';
import 'core/foundation/path.dart';
import 'core/foundation/platform.dart';
import 'core/foundation/windows.dart' as window;
import 'core/http/http.dart';
import 'core/http/providers.dart';
import 'core/info/app_info.dart';
import 'core/info/device_info.dart';
import 'core/info/package_info.dart';
import 'core/settings/providers.dart';
import 'core/settings/settings.dart';
import 'core/tags/categories/providers.dart';
import 'core/tags/configs/providers.dart';
import 'core/tags/favorites/providers.dart';
import 'core/utils/file_utils.dart';
import 'core/widgets/widgets.dart';

Future<void> failsafe(Object e, StackTrace st, BootLogger logger) async {
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();
  final logs = logger.dump();

  runApp(
    ProviderScope(
      overrides: [
        deviceInfoProvider.overrideWithValue(deviceInfo),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: AppFailedToInitialize(
          error: e,
          stackTrace: st,
          logs: logs,
        ),
      ),
    ),
  );
}

Future<void> boot(BootLogger bootLogger) async {
  final appLogger = AppLogger();
  bootLogger.l('Initialize app logger');
  final logger = await loggerWith(appLogger);
  final stopwatch = Stopwatch()..start();
  logger.logI('Start up', 'App Start up');

  if (isDesktopPlatform()) {
    await window.initialize();
  }

  bootLogger.l("Load database's directory");
  final dbDirectory = isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  bootLogger.l('Initialize Hive');
  Hive.init(dbDirectory.path);

  bootLogger.l('Load app info');
  final appInfo = await getAppInfo();

  bootLogger.l('Load boorus from assets');
  final boorus = await loadBoorusFromAssets();

  bootLogger.l('Create booru factory');
  final booruFactory = BooruFactory.from(boorus);

  bootLogger.l('Initialize settings repository');
  final settingRepository = await createSettingsRepo(logger: logger);
  bootLogger.l('Set certificate to trusted certificates');
  try {
    // https://stackoverflow.com/questions/69511057/flutter-on-android-7-certificate-verify-failed-with-letsencrypt-ssl-cert-after-s
    // On Android 7 and below, the Let's Encrypt certificate is not trusted by default and needs to be added manually.
    final cert = await rootBundle.load('assets/ca/isrgrootx1.pem');

    SecurityContext.defaultContext
        .setTrustedCertificatesBytes(cert.buffer.asUint8List());
  } catch (e) {
    // ignore errors here, maybe it's already trusted
  }

  final booruUserRepo = await createBooruConfigsRepo(
    logger: bootLogger,
    booruFactory: booruFactory,
    onCreateNew: (id) async {
      final settings = await settingRepository.load().run().then(
            (value) => value.fold(
              (l) => Settings.defaultSettings,
              (r) => r,
            ),
          );

      bootLogger.l('Save default booru config');
      await settingRepository.save(settings.copyWith(currentBooruConfigId: id));
    },
  );

  bootLogger.l('Load settings');
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

  bootLogger
    ..l('Settings: ${settings.toJson()}')
    ..l('Load current booru config');
  final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(settings);

  bootLogger.l('Load all configs');
  final allConfigs = await booruUserRepo.getAll();

  final favoriteTagsRepoOverride = await createFavoriteTagOverride(
    bootLogger: bootLogger,
  );

  final bookmarkRepoOverride = await createBookmarkRepoProviderOverride(
    bootLogger: bootLogger,
  );

  final tempPath = await getAppTemporaryDirectory();

  bootLogger.l('Initialize misc data box');
  final miscDataBox = await Hive.openBox<String>(
    'misc_data_v1',
    path: tempPath.path,
  );

  bootLogger.l('Initialize package info');
  final packageInfo = await PackageInfo.fromPlatform();

  final tagInfoOverride = await createTagInfoOverride(
    bootLogger: bootLogger,
  );

  bootLogger.l('Initialize device info');
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  bootLogger.l('Initialize i18n');
  await ensureI18nInitialized();

  bootLogger.l('Load supported languages');
  final supportedLanguages = await loadLanguageNames();

  FlutterError.demangleStackTrace = (stack) {
    if (stack is Trace) return stack.vmTrace;
    if (stack is Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  if (settings.clearImageCacheOnStartup) {
    logger.logI('Start up', 'Clearing image cache on startup');
    bootLogger.l('Clear image cache');
    await clearImageCache();
  }

  HttpOverrides.global = AppHttpOverrides();

  // Prepare for Android 15
  unawaited(showSystemStatus());

  logger.logI(
    'Start up',
    'Initialization done in ${stopwatch.elapsed.inMilliseconds}ms',
  );
  stopwatch.stop();

  bootLogger.l('Run app');

  runApp(
    Reboot(
      initialData: RebootData(
        config: initialConfig ?? BooruConfig.empty,
        configs: allConfigs,
        settings: settings,
      ),
      builder: (context, data) => BooruLocalization(
        child: ProviderScope(
          overrides: [
            booruEngineRegistryProvider.overrideWith(
              (ref) => ref.watch(booruInitEngineProvider(booruFactory)),
            ),
            favoriteTagsRepoOverride,
            booruFactoryProvider.overrideWithValue(booruFactory),
            tagInfoOverride,
            settingsRepoProvider.overrideWithValue(settingRepository),
            settingsNotifierProvider
                .overrideWith(() => SettingsNotifier(data.settings)),
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
            bookmarkRepoOverride,
            deviceInfoProvider.overrideWithValue(deviceInfo),
            packageInfoProvider.overrideWithValue(packageInfo),
            appInfoProvider.overrideWithValue(appInfo),
            appLoggerProvider.overrideWithValue(appLogger),
            supportedLanguagesProvider.overrideWithValue(supportedLanguages),
            miscDataBoxProvider.overrideWithValue(miscDataBox),
            booruTagTypePathProvider.overrideWithValue(dbDirectory.path),
          ],
          child: const App(),
        ),
      ),
    ),
  );
}

//FIXME: Duplicate code with the one in boot
final dbPathProvider = FutureProvider<String>((ref) async {
  final dbDirectory = isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  return dbDirectory.path;
});
