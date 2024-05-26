// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:hive/hive.dart';
import 'package:stack_trace/stack_trace.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/metatags/metatags.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/feats/search_histories/search_histories.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/tracking.dart';
import 'app.dart';
import 'foundation/i18n.dart';

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
  bootLogger.l("Initialize app logger");
  final logger = await loggerWith(appLogger);
  final stopwatch = Stopwatch()..start();
  logger.logI('Start up', 'App Start up');

  bootLogger.l("Load database's directory");
  final dbDirectory = isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  bootLogger.l("Initialize Hive");
  Hive.init(dbDirectory.path);

  bootLogger.l("Register search history adapter");
  Hive.registerAdapter(SearchHistoryHiveObjectAdapter());
  bootLogger.l("Register bookmark adapter");
  Hive.registerAdapter(BookmarkHiveObjectAdapter());
  bootLogger.l("Register favorite tag adapter");
  Hive.registerAdapter(FavoriteTagHiveObjectAdapter());

  if (isDesktopPlatform()) {
    bootLogger.l("Initialize window manager");
    doWhenWindowReady(() {
      const iPhoneSize = Size(375, 812);
      const initialSize = Size(1000, 700);
      const minSize = Size(950, 500);
      appWindow.minSize = kPreferredLayout.isMobile ? iPhoneSize : minSize;
      appWindow.size = kPreferredLayout.isMobile ? iPhoneSize : initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  if (isLinux() || isWindows() || isIOS()) {
    fvp.registerWith(
      options: {
        'platforms': [
          'linux',
          'ios',
          'windows',
        ],
      },
    );
  }

  bootLogger.l("Load app info");
  final appInfo = await getAppInfo();

  bootLogger.l("Load boorus from assets");
  final boorus = await loadBoorusFromAssets();

  bootLogger.l("Create booru factory");
  final booruFactory = BooruFactory.from(boorus);

  bootLogger.l("Initialize settings repository");
  final settingRepository = SettingsRepositoryLoggerInterceptor(
    SettingsRepositoryHive(
      Hive.openBox('settings'),
    ),
    logger: logger,
  );

  bootLogger.l("Set certificate to trusted certificates");
  try {
    // https://stackoverflow.com/questions/69511057/flutter-on-android-7-certificate-verify-failed-with-letsencrypt-ssl-cert-after-s
    // On Android 7 and below, the Let's Encrypt certificate is not trusted by default and needs to be added manually.
    final cert = await rootBundle.load('assets/ca/isrgrootx1.pem');

    SecurityContext.defaultContext
        .setTrustedCertificatesBytes(cert.buffer.asUint8List());
  } catch (e) {
    // ignore errors here, maybe it's already trusted
  }

  Box<String> booruConfigBox;
  bootLogger.l("Initialize booru config box");
  if (await Hive.boxExists('booru_configs')) {
    bootLogger.l("Open booru config box");
    booruConfigBox = await Hive.openBox<String>('booru_configs');
  } else {
    bootLogger.l("Create booru config box");
    booruConfigBox = await Hive.openBox<String>('booru_configs');
    bootLogger.l("Add default booru config");
    final id = await booruConfigBox
        .add(HiveBooruConfigRepository.defaultValue(booruFactory));

    final settings =
        await settingRepository.load().run().then((value) => value.fold(
              (l) => Settings.defaultSettings,
              (r) => r,
            ));

    bootLogger.l("Save default booru config");
    await settingRepository.save(settings.copyWith(currentBooruConfigId: id));
  }

  bootLogger.l("Total booru config: ${booruConfigBox.length}");

  bootLogger.l("Initialize booru user repository");
  final booruUserRepo = HiveBooruConfigRepository(box: booruConfigBox);

  bootLogger.l("Load settings");
  final settings =
      await settingRepository.load().run().then((value) => value.fold(
            (l) => Settings.defaultSettings,
            (r) => r,
          ));

  bootLogger.l("Settings: ${settings.toJson()}");

  bootLogger.l("Load current booru config");
  final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(settings);

  Box<String> userMetatagBox;
  bootLogger.l("Initialize user metatag box");
  if (await Hive.boxExists('user_metatags')) {
    bootLogger.l("Open user metatag box");
    userMetatagBox = await Hive.openBox<String>('user_metatags');
  } else {
    bootLogger.l("Create user metatag box");
    userMetatagBox = await Hive.openBox<String>('user_metatags');
    for (final e in [
      'age',
      'rating',
      'order',
      'score',
      'id',
      'user',
    ]) {
      await userMetatagBox.put(e, e);
    }
  }
  final userMetatagRepo = UserMetatagRepository(box: userMetatagBox);

  bootLogger.l("Initialize search history repository");
  final searchHistoryBox =
      await Hive.openBox<SearchHistoryHiveObject>('search_history');
  final searchHistoryRepo = SearchHistoryRepositoryHive(
    db: searchHistoryBox,
  );

  bootLogger.l("Initialize favorite tag repository");
  final favoriteTagsBox =
      await Hive.openBox<FavoriteTagHiveObject>('favorite_tags');
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  bootLogger.l("Initialize global blacklisted tag repository");
  final globalBlacklistedTags = HiveBlacklistedTagRepository();
  await globalBlacklistedTags.init();

  bootLogger.l("Initialize bookmark repository");
  final bookmarkBox = await Hive.openBox<BookmarkHiveObject>("favorites");
  final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

  final tempPath = await getTemporaryDirectory();

  bootLogger.l("Initialize misc data box");
  final miscDataBox = await Hive.openBox<String>(
    'misc_data_v1',
    path: tempPath.path,
  );

  bootLogger.l("Initialize danbooru creator box");
  final danbooruCreatorBox = await Hive.openBox(
    '${Uri.encodeComponent(initialConfig?.url ?? 'danbooru')}_creators_v1',
    path: tempPath.path,
  );

  bootLogger.l("Initialize package info");
  final packageInfo = await PackageInfo.fromPlatform();

  bootLogger.l("Initialize tag info");
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());

  bootLogger.l("Initialize device info");
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  bootLogger.l("Initialize i18n");
  await ensureI18nInitialized();

  bootLogger.l("Load supported languages");
  final supportedLanguages = await loadLanguageNames();

  bootLogger.l("Initialize tracking");
  final (firebaseAnalytics, crashlyticsReporter) =
      await initializeTracking(settings);

  bootLogger.l("Initialize error handlers");
  initializeErrorHandlers(settings, crashlyticsReporter);

  bootLogger.l("Initialize download notifications");
  final downloadNotifications = await DownloadNotifications.create();

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is Trace) return stack.vmTrace;
    if (stack is Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  if (settings.clearImageCacheOnStartup) {
    logger.logI('Start up', 'Clearing image cache on startup');
    bootLogger.l("Clear image cache");
    await clearImageCache();
  }

  logger.logI('Start up',
      'Initialization done in ${stopwatch.elapsed.inMilliseconds}ms');
  stopwatch.stop();

  void run() {
    runApp(
      Reboot(
        initialConfig: initialConfig ?? BooruConfig.empty,
        builder: (context, config) => BooruLocalization(
          child: ProviderScope(
            overrides: [
              favoriteTagRepoProvider.overrideWithValue(favoriteTagsRepo),
              searchHistoryRepoProvider.overrideWithValue(searchHistoryRepo),
              booruFactoryProvider.overrideWithValue(booruFactory),
              tagInfoProvider.overrideWithValue(tagInfo),
              settingsRepoProvider.overrideWithValue(settingRepository),
              settingsProvider.overrideWith(() => SettingsNotifier(settings)),
              booruConfigRepoProvider.overrideWithValue(booruUserRepo),
              currentBooruConfigProvider.overrideWith(
                  () => CurrentBooruConfigNotifier(initialConfig: config)),
              globalBlacklistedTagRepoProvider
                  .overrideWithValue(globalBlacklistedTags),
              httpCacheDirProvider.overrideWithValue(tempPath),
              loggerProvider.overrideWithValue(logger),
              bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
              downloadNotificationProvider
                  .overrideWithValue(downloadNotifications),
              deviceInfoProvider.overrideWithValue(deviceInfo),
              danbooruUserMetatagRepoProvider
                  .overrideWithValue(userMetatagRepo),
              packageInfoProvider.overrideWithValue(packageInfo),
              appInfoProvider.overrideWithValue(appInfo),
              appLoggerProvider.overrideWithValue(appLogger),
              supportedLanguagesProvider.overrideWithValue(supportedLanguages),
              danbooruCreatorHiveBoxProvider
                  .overrideWithValue(danbooruCreatorBox),
              miscDataBoxProvider.overrideWithValue(miscDataBox),
              booruTagTypePathProvider.overrideWithValue(dbDirectory.path),
              if (firebaseAnalytics != null)
                analyticsProvider.overrideWithValue(firebaseAnalytics),
              if (crashlyticsReporter != null)
                errorReporterProvider.overrideWithValue(crashlyticsReporter),
            ],
            child: App(
              appName: appInfo.appName,
              initialSettings: settings,
            ),
          ),
        ),
      ),
    );
  }

  bootLogger.l("Run app");
  run();
}
