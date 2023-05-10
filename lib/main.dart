// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:video_player_win/video_player_win.dart';

// Project imports:
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/blacklists/blacklisted_tags_cubit.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/cache_cubit.dart';
import 'package:boorusama/core/application/current_booru_notifier.dart';
import 'package:boorusama/core/application/device_storage_permission/device_storage_permission.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/downloads/notification.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags/favorite_tag_repository.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/error.dart';
import 'package:boorusama/core/infra/blacklists/hive_blacklisted_tag_repository.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_object.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_repository.dart';
import 'package:boorusama/core/infra/boorus/booru_config_repository_hive.dart';
import 'package:boorusama/core/infra/boorus/current_booru_repository_settings.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/infra/loggers.dart' as l;
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/infra/repositories/favorite_tag_hive_object.dart';
import 'package:boorusama/core/infra/repositories/favorite_tag_repository.dart';
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'package:boorusama/core/infra/repositories/search_histories.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/infra/services/user_agent_generator_impl.dart';
import 'package:boorusama/core/infra/settings/settings.dart';
import 'package:boorusama/core/infra/settings/settings_repository_logger_interceptor.dart';
import 'package:boorusama/core/internationalization.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/provider.dart';
import 'app.dart';

const savedSearchHelpUrl =
    'https://safebooru.donmai.us/wiki_pages/help%3Asaved_searches';

void main() async {
  final logger = await l.logger();
  final stopwatch = Stopwatch()..start();
  logger.logI('Start up', 'App Start up');
  logger.logI('Start up', 'Initialize Flutter Widgets');

  WidgetsFlutterBinding.ensureInitialized();

  if (!isWeb()) {
    final dbDirectory = isAndroid()
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();

    logger.logI('Start up', 'Initialize Hive');

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

  logger.logI('Start up', 'Initialize Booru data');

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

  logger.logI('Start up', 'Initialize booru configs ');

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

  logger.logI('Start up', 'Initialize settings');

  final settings =
      await settingRepository.load().run().then((value) => value.fold(
            (l) => Settings.defaultSettings,
            (r) => r,
          ));

  logger.logI('Start up', 'Initialize meta tags');
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

  logger.logI('Start up', 'Initialize search history');

  final searchHistoryBox =
      await Hive.openBox<SearchHistoryHiveObject>('search_history');
  final searchHistoryRepo = SearchHistoryRepositoryHive(
    db: searchHistoryBox,
  );

  logger.logI('Start up', 'Initialize favorite tags');
  final favoriteTagsBox =
      await Hive.openBox<FavoriteTagHiveObject>('favorite_tags');
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  logger.logI('Start up', 'Initialize global blacklisted tags');
  final globalBlacklistedTags = HiveBlacklistedTagRepository();
  await globalBlacklistedTags.init();

  logger.logI('Start up', 'Initialize bookmarks');
  final bookmarkBox = await Hive.openBox<BookmarkHiveObject>("favorites");
  final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

  logger.logI('Start up', 'Initialize app info and package info');
  final packageInfo = PackageInfoProvider(await getPackageInfo());
  final appInfo = AppInfoProvider(await getAppInfo());
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());
  logger.logI('Start up', 'Initialize device info');
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  final tempPath = await getTemporaryDirectory();

  final userAgentGenerator = UserAgentGeneratorImpl(
    appVersion: packageInfo.packageInfo.version,
    appName: appInfo.appInfo.appName,
  );

  logger.logI('Start up', 'Initialize downloader');

  if (isWindows()) WindowsVideoPlayer.registerWith();

  final previewImageCacheManager = PreviewImageCacheManager();
  final previewPreloader = PostPreviewPreloaderImp(
    previewImageCacheManager,
    httpHeaders: {
      'User-Agent': userAgentGenerator.generate(),
    },
  );

  final currentBooruRepo = CurrentBooruRepositorySettings(
    settingRepository,
    booruUserRepo,
  );

  final appDioProvider = DioProvider(tempPath, userAgentGenerator, logger);

  final booruUserIdProvider =
      BooruUserIdentityProviderImpl(appDioProvider, booruFactory);

  final favoriteTagBloc =
      FavoriteTagBloc(favoriteTagRepository: favoriteTagsRepo);

  final initialConfig = await currentBooruRepo.get();

  logger.logI('Start up', 'Initialize I18n');
  await ensureI18nInitialized();

  logger.logI('Start up', 'Initialize Analytics');
  await initializeAnalytics(settings);
  initializeErrorHandlers(settings);

  final downloadNotifications = await DownloadNotifications.create();

  final dioDownloadService = DioDownloadService(
    appDioProvider.getDio(null),
    downloadNotifications,
  );

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  logger.logI('Start up',
      'Initializtion done in ${stopwatch.elapsed.inMilliseconds}ms');
  stopwatch.stop();

  void run() {
    runApp(
      BooruLocalization(
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: packageInfo),
            RepositoryProvider.value(value: appInfo),
            RepositoryProvider.value(value: deviceInfo),
            RepositoryProvider.value(value: tagInfo),
            RepositoryProvider<DownloadService>.value(
                value: dioDownloadService),
            RepositoryProvider.value(value: userMetatagRepo),
            RepositoryProvider<FavoriteTagRepository>.value(
              value: favoriteTagsRepo,
            ),
            RepositoryProvider<PostPreviewPreloader>.value(
              value: previewPreloader,
            ),
            RepositoryProvider<PreviewImageCacheManager>.value(
              value: previewImageCacheManager,
            ),
            RepositoryProvider<UserAgentGenerator>.value(
              value: userAgentGenerator,
            ),
            RepositoryProvider<BooruFactory>.value(
              value: booruFactory,
            ),
            RepositoryProvider<BooruConfigRepository>.value(
              value: booruUserRepo,
            ),
            RepositoryProvider<SearchHistoryRepository>.value(
              value: searchHistoryRepo,
            ),
            RepositoryProvider<SettingsRepository>.value(
              value: settingRepository,
            ),
            RepositoryProvider<BooruUserIdentityProvider>.value(
              value: booruUserIdProvider,
            ),
            RepositoryProvider<CurrentBooruConfigRepository>.value(
              value: currentBooruRepo,
            ),
            RepositoryProvider<BlacklistedTagRepository>.value(
              value: globalBlacklistedTags,
            ),
            RepositoryProvider<BookmarkRepository>.value(
              value: bookmarkRepo,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => NetworkBloc(),
                lazy: false,
              ),
              BlocProvider.value(
                value: favoriteTagBloc..add(const FavoriteTagFetched()),
              ),
              BlocProvider(
                create: (context) =>
                    ThemeBloc(initialTheme: settings.themeMode),
              ),
              if (isAndroid() || isIOS())
                BlocProvider(
                  create: (context) => DeviceStoragePermissionBloc(
                    deviceInfo: deviceInfo,
                    initialStatus: PermissionStatus.denied,
                  )..add(DeviceStoragePermissionFetched()),
                ),
              BlocProvider(
                create: (context) => BlacklistedTagCubit(globalBlacklistedTags),
              ),
              BlocProvider(
                create: (context) => BookmarkCubit(
                  settingsRepository: settingRepository,
                  bookmarkRepository: context.read<BookmarkRepository>(),
                  downloadService: dioDownloadService,
                )..getAllBookmarksWithToast(),
              ),
              BlocProvider(create: (context) => CacheCubit()),
            ],
            child: ProviderScope(
              overrides: [
                searchHistoryRepoProvider.overrideWithValue(searchHistoryRepo),
                currentBooruConfigRepoProvider
                    .overrideWithValue(currentBooruRepo),
                booruFactoryProvider.overrideWithValue(booruFactory),
                tagInfoProvider.overrideWithValue(tagInfo),
                settingsRepoProvider.overrideWithValue(settingRepository),
                settingsProvider.overrideWith(() => SettingsNotifier(settings)),
                booruUserIdentityProviderProvider
                    .overrideWithValue(booruUserIdProvider),
                authenticationProvider
                    .overrideWith(() => AuthenticationNotifier()),
                booruConfigRepoProvider.overrideWithValue(booruUserRepo),
                currentBooruConfigProvider.overrideWith(
                    () => CurrentBooruConfigNotifier(initialConfig!)),
                dioProvider.overrideWithValue(appDioProvider),
              ],
              child: App(settings: settings),
            ),
          ),
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
