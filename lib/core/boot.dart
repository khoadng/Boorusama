// Dart imports:
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
import '../boorus/danbooru/tags/user_metatags/providers.dart';
import '../boorus/danbooru/users/creator/providers.dart';
import 'analytics.dart';
import 'app.dart';
import 'blacklists/hive/tag_repository.dart';
import 'blacklists/providers.dart';
import 'bookmarks/hive/object.dart';
import 'bookmarks/hive/repository.dart';
import 'bookmarks/providers.dart';
import 'boorus.dart';
import 'boorus/providers.dart';
import 'cache/providers.dart';
import 'configs/config.dart';
import 'configs/current.dart';
import 'configs/manage.dart';
import 'downloads/bulks/notifications.dart';
import 'downloads/notifications.dart';
import 'foundation/error.dart';
import 'foundation/http.dart';
import 'foundation/loggers.dart';
import 'foundation/mobile.dart';
import 'foundation/path.dart';
import 'foundation/platform.dart';
import 'foundation/windows.dart' as window;
import 'http/providers.dart';
import 'info/app_info.dart';
import 'info/device_info.dart';
import 'info/package_info.dart';
import 'search/boot.dart';
import 'settings.dart';
import 'settings/data.dart';
import 'tags/categories/providers.dart';
import 'tags/configs/providers.dart';
import 'tags/favorites/providers.dart';
import 'tracking.dart';
import 'utils/file_utils.dart';
import 'widgets/widgets.dart';

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

  bootLogger.l('Register bookmark adapter');
  Hive.registerAdapter(BookmarkHiveObjectAdapter());

  if (isDesktopPlatform() || isIOS()) {
    fvp.registerWith(
      options: {
        'platforms': [
          'linux',
          'ios',
          'windows',
          'macos',
        ],
      },
    );
  }

  bootLogger.l('Load app info');
  final appInfo = await getAppInfo();

  bootLogger.l('Load boorus from assets');
  final boorus = await loadBoorusFromAssets();

  bootLogger.l('Create booru factory');
  final booruFactory = BooruFactory.from(boorus);

  bootLogger.l('Initialize settings repository');
  final settingRepository = SettingsRepositoryLoggerInterceptor(
    SettingsRepositoryHive(
      Hive.openBox('settings'),
    ),
    logger: logger,
  );

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

  bootLogger.l('Settings: ${settings.toJson()}');

  bootLogger.l('Load current booru config');
  final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(settings);

  bootLogger.l('Load all configs');
  final allConfigs = await booruUserRepo.getAll();

  final userMetatagRepoOverride = await createUserMetatagRepoOverride(
    bootLogger: bootLogger,
  );

  final searchHistoryRepoOverride = await createSearchHistoryRepoOverride(
    logger: bootLogger,
  );

  final favoriteTagsRepoOverride = await createFavoriteTagOverride(
    bootLogger: bootLogger,
  );

  bootLogger.l('Initialize global blacklisted tag repository');
  final globalBlacklistedTags = HiveBlacklistedTagRepository();
  await globalBlacklistedTags.init();

  bootLogger.l('Initialize bookmark repository');
  final bookmarkBox = await Hive.openBox<BookmarkHiveObject>('favorites');
  final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

  final tempPath = await getAppTemporaryDirectory();

  bootLogger.l('Initialize misc data box');
  final miscDataBox = await Hive.openBox<String>(
    'misc_data_v1',
    path: tempPath.path,
  );

  final danbooruCreatorBoxOverride = await createCreatorBoxOverride(
    initialConfig: initialConfig,
    tempPath: tempPath,
    bootLogger: bootLogger,
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

  bootLogger.l('Initialize tracking');
  final (firebaseAnalytics, crashlyticsReporter) =
      await initializeTracking(settings);

  bootLogger.l('Initialize error handlers');
  initializeErrorHandlers(
    settings.dataCollectingStatus == DataCollectingStatus.allow,
    crashlyticsReporter,
  );

  bootLogger.l('Initialize download notifications');
  final downloadNotifications = await DownloadNotifications.create();
  final bulkDownloadNotifications = await BulkDownloadNotifications.create();

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
  showSystemStatus();

  logger.logI(
    'Start up',
    'Initialization done in ${stopwatch.elapsed.inMilliseconds}ms',
  );
  stopwatch.stop();

  void run() {
    runApp(
      Reboot(
        initialConfigs: allConfigs,
        initialConfig: initialConfig ?? BooruConfig.empty,
        builder: (context, config, configs) => BooruLocalization(
          child: ProviderScope(
            overrides: [
              favoriteTagsRepoOverride,
              searchHistoryRepoOverride,
              booruFactoryProvider.overrideWithValue(booruFactory),
              tagInfoOverride,
              settingsRepoProvider.overrideWithValue(settingRepository),
              settingsNotifierProvider
                  .overrideWith(() => SettingsNotifier(settings)),
              booruConfigRepoProvider.overrideWithValue(booruUserRepo),
              booruConfigProvider.overrideWith(
                () => BooruConfigNotifier(
                  initialConfigs: configs,
                ),
              ),
              initialSettingsBooruConfigProvider.overrideWithValue(config),
              globalBlacklistedTagRepoProvider
                  .overrideWithValue(globalBlacklistedTags),
              httpCacheDirProvider.overrideWithValue(tempPath),
              loggerProvider.overrideWithValue(logger),
              bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
              downloadNotificationProvider
                  .overrideWithValue(downloadNotifications),
              bulkDownloadNotificationProvider
                  .overrideWithValue(bulkDownloadNotifications),
              deviceInfoProvider.overrideWithValue(deviceInfo),
              userMetatagRepoOverride,
              packageInfoProvider.overrideWithValue(packageInfo),
              appInfoProvider.overrideWithValue(appInfo),
              appLoggerProvider.overrideWithValue(appLogger),
              supportedLanguagesProvider.overrideWithValue(supportedLanguages),
              danbooruCreatorBoxOverride,
              miscDataBoxProvider.overrideWithValue(miscDataBox),
              booruTagTypePathProvider.overrideWithValue(dbDirectory.path),
              if (firebaseAnalytics != null)
                analyticsProvider.overrideWithValue(firebaseAnalytics),
              if (crashlyticsReporter != null)
                errorReporterProvider.overrideWithValue(crashlyticsReporter),
            ],
            child: const App(),
          ),
        ),
      ),
    );
  }

  bootLogger.l('Run app');
  run();
}
