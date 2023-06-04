// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:video_player_win/video_player_win.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/error.dart';
import 'package:boorusama/core/infra/blacklists/hive_blacklisted_tag_repository.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_object.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_repository.dart';
import 'package:boorusama/core/infra/boorus/booru_config_repository_hive.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/infra/loggers.dart' as l;
import 'package:boorusama/core/infra/loggers.dart';
import 'package:boorusama/core/infra/repositories/favorite_tag_hive_object.dart';
import 'package:boorusama/core/infra/repositories/favorite_tag_repository.dart';
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'package:boorusama/core/infra/repositories/search_histories.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/infra/settings/settings.dart';
import 'package:boorusama/core/infra/settings/settings_repository_logger_interceptor.dart';
import 'package:boorusama/core/networking/networking.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'app.dart';
import 'i18n.dart';

void main() async {
  final uiLogger = UILogger();
  final logger = await l.loggerWith(uiLogger);
  final stopwatch = Stopwatch()..start();
  logger.logI('Start up', 'App Start up');

  WidgetsFlutterBinding.ensureInitialized();

  if (!isWeb()) {
    final dbDirectory = isAndroid()
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();

    Hive
      ..init(dbDirectory.path)
      ..registerAdapter(SearchHistoryHiveObjectAdapter())
      ..registerAdapter(BookmarkHiveObjectAdapter())
      ..registerAdapter(FavoriteTagHiveObjectAdapter());
  }

  if (isDesktopPlatform()) {
    doWhenWindowReady(() {
      const initialSize = Size(1024, 600);
      const minSize = Size(300, 300);
      appWindow.minSize = minSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  final booruFactory = BooruFactory.from(
    await loadBooruList(),
    await loadBooruSaltList(),
  );

  final settingRepository = SettingsRepositoryLoggerInterceptor(
    SettingsRepositoryHive(
      Hive.openBox('settings'),
    ),
    logger: logger,
  );

  Box<String> booruConfigBox;
  if (await Hive.boxExists('booru_configs')) {
    booruConfigBox = await Hive.openBox<String>('booru_configs');
  } else {
    booruConfigBox = await Hive.openBox<String>('booru_configs');
    final id = await booruConfigBox
        .add(HiveBooruConfigRepository.defaultValue(booruFactory));
    final settings =
        await settingRepository.load().run().then((value) => value.fold(
              (l) => Settings.defaultSettings,
              (r) => r,
            ));
    await settingRepository.save(settings.copyWith(currentBooruConfigId: id));
  }
  final booruUserRepo = HiveBooruConfigRepository(box: booruConfigBox);

  final settings =
      await settingRepository.load().run().then((value) => value.fold(
            (l) => Settings.defaultSettings,
            (r) => r,
          ));

  final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(settings);

  Box<String> userMetatagBox;
  if (await Hive.boxExists('user_metatags')) {
    userMetatagBox = await Hive.openBox<String>('user_metatags');
  } else {
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

  final searchHistoryBox =
      await Hive.openBox<SearchHistoryHiveObject>('search_history');
  final searchHistoryRepo = SearchHistoryRepositoryHive(
    db: searchHistoryBox,
  );

  final favoriteTagsBox =
      await Hive.openBox<FavoriteTagHiveObject>('favorite_tags');
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  final globalBlacklistedTags = HiveBlacklistedTagRepository();
  await globalBlacklistedTags.init();

  final bookmarkBox = await Hive.openBox<BookmarkHiveObject>("favorites");
  final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

  final packageInfo = await PackageInfo.fromPlatform();
  final appInfo = await getAppInfo();
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  final tempPath = await getTemporaryDirectory();

  if (isWindows()) WindowsVideoPlayer.registerWith();

  await ensureI18nInitialized();
  final supportedLanguages = await loadLanguageNames();

  await initializeAnalytics(settings);
  initializeErrorHandlers(settings);

  final downloadNotifications = await DownloadNotifications.create();

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  logger.logI('Start up',
      'Initialization done in ${stopwatch.elapsed.inMilliseconds}ms');
  stopwatch.stop();

  void run() {
    runApp(
      BooruLocalization(
        child: ProviderScope(
          overrides: [
            favoriteTagRepoProvider.overrideWithValue(favoriteTagsRepo),
            searchHistoryRepoProvider.overrideWithValue(searchHistoryRepo),
            booruFactoryProvider.overrideWithValue(booruFactory),
            tagInfoProvider.overrideWithValue(tagInfo),
            settingsRepoProvider.overrideWithValue(settingRepository),
            settingsProvider.overrideWith(() => SettingsNotifier(settings)),
            booruConfigRepoProvider.overrideWithValue(booruUserRepo),
            currentBooruConfigProvider.overrideWith(() =>
                CurrentBooruConfigNotifier(
                    initialConfig: initialConfig ?? BooruConfig.empty)),
            globalBlacklistedTagRepoProvider
                .overrideWithValue(globalBlacklistedTags),
            httpCacheDirProvider.overrideWithValue(tempPath),
            loggerProvider.overrideWithValue(logger),
            bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
            downloadNotificationProvider
                .overrideWithValue(downloadNotifications),
            deviceInfoProvider.overrideWithValue(deviceInfo),
            danbooruUserMetatagRepoProvider.overrideWithValue(userMetatagRepo),
            packageInfoProvider.overrideWithValue(packageInfo),
            appInfoProvider.overrideWithValue(appInfo),
            uiLoggerProvider.overrideWithValue(uiLogger),
            supportedLanguagesProvider.overrideWithValue(supportedLanguages),
          ],
          child: App(settings: settings),
        ),
      ),
    );
  }

  run();
}

class DioProvider {
  DioProvider(
    this.dir,
    this.generator,
    this.loggerService,
  );

  final Directory dir;
  final UserAgentGenerator generator;
  final l.LoggerService loggerService;

  Dio getDio(String? baseUrl) => dio(dir, baseUrl, generator, loggerService);
}
