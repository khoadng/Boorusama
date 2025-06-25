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
import 'boorus/anime-pictures/anime_pictures.dart';
import 'boorus/danbooru/danbooru.dart';
import 'boorus/e621/e621.dart';
import 'boorus/gelbooru/gelbooru.dart';
import 'boorus/gelbooru_v1/gelbooru_v1.dart';
import 'boorus/gelbooru_v2/gelbooru_v2.dart';
import 'boorus/hybooru/hybooru.dart';
import 'boorus/hydrus/hydrus.dart';
import 'boorus/moebooru/moebooru.dart';
import 'boorus/philomena/philomena.dart';
import 'boorus/providers.dart';
import 'boorus/sankaku/sankaku.dart';
import 'boorus/shimmie2/shimmie2.dart';
import 'boorus/szurubooru/szurubooru.dart';
import 'boorus/zerochan/zerochan.dart';
import 'core/app.dart';
import 'core/app_rating/src/providers.dart';
import 'core/boorus/booru/booru.dart';
import 'core/boorus/booru/providers.dart';
import 'core/boorus/engine/engine.dart';
import 'core/boorus/engine/providers.dart';
import 'core/cache/providers.dart';
import 'core/configs/config.dart';
import 'core/configs/config/data.dart';
import 'core/configs/manage/providers.dart';
import 'core/foundation/boot.dart';
import 'core/foundation/boot/providers.dart';
import 'core/foundation/iap/iap.dart';
import 'core/foundation/loggers.dart';
import 'core/foundation/mobile.dart';
import 'core/foundation/path.dart';
import 'core/foundation/platform.dart';
import 'core/foundation/windows.dart' as window;
import 'core/google/providers.dart';
import 'core/http/http.dart';
import 'core/http/providers.dart';
import 'core/info/app_info.dart';
import 'core/info/device_info.dart';
import 'core/info/package_info.dart';
import 'core/settings/providers.dart';
import 'core/settings/settings.dart';
import 'core/tags/configs/providers.dart';
import 'core/utils/file_utils.dart';
import 'core/widgets/widgets.dart';

Future<void> boot(BootData bootData) async {
  final bootLogger = bootData.bootLogger;
  final logger = bootData.logger;
  final appLogger = bootData.appLogger;

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

  final booruRegistry = BooruRegistry()
    ..register(
      BooruType.hybooru,
      createHybooru(),
    )
    ..register(
      BooruType.animePictures,
      createAnimePictures(),
    )
    ..register(
      BooruType.hydrus,
      createHydrus(),
    )
    ..register(
      BooruType.szurubooru,
      createSzurubooru(),
    )
    ..register(
      BooruType.shimmie2,
      createShimmie2(),
    )
    ..register(
      BooruType.philomena,
      createPhilomena(),
    )
    ..register(
      BooruType.sankaku,
      createSankaku(),
    )
    ..register(
      BooruType.moebooru,
      createMoebooru(),
    )
    ..register(
      BooruType.zerochan,
      createZerochan(),
    )
    ..register(
      BooruType.e621,
      createE621(),
    )
    ..register(
      BooruType.gelbooruV2,
      createGelbooruV2(),
    )
    ..register(
      BooruType.gelbooruV1,
      createGelbooruV1(),
    )
    ..register(
      BooruType.gelbooru,
      createGelbooru(),
    )
    ..register(
      BooruType.danbooru,
      createDanbooru(),
    );

  bootLogger.l('Load boorus from assets');
  final boorus = await loadBoorusFromAssets(booruRegistry);

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
              (ref) => ref.watch(
                booruInitEngineProvider(
                  (db: boorus, registry: booruRegistry),
                ),
              ),
            ),
            appRatingProvider.overrideWithValue(bootData.appRatingService),
            iapFuncProvider.overrideWithValue(bootData.iapFunc),
            isFossBuildProvider.overrideWithValue(bootData.isFossBuild),
            booruDbProvider.overrideWithValue(boorus),
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

//FIXME: Duplicate code with the one in boot
final dbPathProvider = FutureProvider<String>((ref) async {
  final dbDirectory = isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  return dbDirectory.path;
});
