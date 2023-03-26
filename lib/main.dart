// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player_win/video_player_win.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/api.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/device_storage_permission/device_storage_permission.dart';
import 'package:boorusama/core/application/download/download_service.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags/favorite_tag_repository.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/error.dart';
import 'package:boorusama/core/infra/boorus/booru_config_repository_hive.dart';
import 'package:boorusama/core/infra/boorus/current_booru_repository_settings.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/infra/repositories/favorite_tag_hive_object.dart';
import 'package:boorusama/core/infra/repositories/favorite_tag_repository.dart';
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'package:boorusama/core/infra/repositories/search_histories.dart';
import 'package:boorusama/core/infra/services/download_service_flutter_downloader.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/infra/services/user_agent_generator_impl.dart';
import 'package:boorusama/core/infra/settings/settings.dart';
import 'package:boorusama/core/internationalization.dart';
import 'app.dart';

const cheatsheetUrl = 'https://safebooru.donmai.us/wiki_pages/help:cheatsheet';
const savedSearchHelpUrl =
    'https://safebooru.donmai.us/wiki_pages/help%3Asaved_searches';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!isWeb()) {
    final dbDirectory = isAndroid()
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();

    Hive
      ..init(dbDirectory.path)
      ..registerAdapter(SearchHistoryHiveObjectAdapter())
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

  final settingRepository = SettingsRepositoryHive(
    Hive.openBox('settings'),
    Settings.defaultSettings,
  );

  Box<String> booruConfigBox;
  if (await Hive.boxExists('booru_configs')) {
    booruConfigBox = await Hive.openBox<String>('booru_configs');
  } else {
    booruConfigBox = await Hive.openBox<String>('booru_configs');
    final id =
        await booruConfigBox.add(HiveBooruConfigRepository.defaultValue());
    final settings = await settingRepository.load();
    await settingRepository.save(settings.copyWith(currentBooruConfigId: id));
  }
  final booruUserRepo = HiveBooruConfigRepository(box: booruConfigBox);

  final settings = await settingRepository.load();

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

  final booruFactory = BooruFactory.from(await loadBooruList());
  final packageInfo = PackageInfoProvider(await getPackageInfo());
  final appInfo = AppInfoProvider(await getAppInfo());
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  final tempPath = await getTemporaryDirectory();

  final userAgentGenerator = UserAgentGeneratorImpl(
    appVersion: packageInfo.packageInfo.version,
    appName: appInfo.appInfo.appName,
  );

  //TODO: this notification is only used for download feature
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
    macOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _localNotificatonHandler,
  );

  final downloader = await createDownloader(
    settings.downloadMethod,
    deviceInfo,
    flutterLocalNotificationsPlugin,
    userAgentGenerator,
  );
  final bulkDownloader = BulkDownloader<DanbooruPost>(
    idSelector: (item) => item.id,
    downloadUrlSelector: (item) => item.downloadUrl,
    fileNameGenerator: Md5OnlyFileNameGenerator(),
    deviceInfo: deviceInfo,
  );

  if (isMobilePlatform()) {
    await bulkDownloader.init();
  }

  if (isWindows()) WindowsVideoPlayer.registerWith();

  final previewImageCacheManager = PreviewImageCacheManager();
  final previewPreloader = PostPreviewPreloaderImp(
    previewImageCacheManager,
    httpHeaders: {
      'User-Agent': userAgentGenerator.generate(),
    },
  );

  final settingsCubit = SettingsCubit(
    settingRepository: settingRepository,
    settings: settings,
  );

  final currentBooruRepo = CurrentBooruRepositorySettings(
    settingRepository,
    booruUserRepo,
  );

  final dioProvider = DioProvider(tempPath, userAgentGenerator);

  final booruUserIdProvider = BooruUserIdentityProviderImpl(dioProvider);

  final favoriteTagBloc =
      FavoriteTagBloc(favoriteTagRepository: favoriteTagsRepo);

  await ensureI18nInitialized();
  await initializeAnalytics(settings);
  initializeErrorHandlers(settings);

  final manageBooruUserBloc = ManageBooruUserBloc(
    userBooruRepository: booruUserRepo,
    booruFactory: booruFactory,
    booruUserIdentityProvider: booruUserIdProvider,
  );

  void run() {
    runApp(
      BooruLocalization(
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: packageInfo),
            RepositoryProvider.value(value: appInfo),
            RepositoryProvider.value(value: deviceInfo),
            RepositoryProvider.value(value: tagInfo),
            RepositoryProvider<DownloadService>.value(value: downloader),
            RepositoryProvider<BulkDownloader<DanbooruPost>>.value(
              value: bulkDownloader,
            ),
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
            RepositoryProvider<DioProvider>.value(
              value: dioProvider,
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
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => NetworkBloc(),
                lazy: false,
              ),
              BlocProvider.value(
                value: CurrentBooruBloc(
                  settingsCubit: settingsCubit,
                  booruFactory: booruFactory,
                  userBooruRepository: booruUserRepo,
                )..add(CurrentBooruFetched(settings)),
              ),
              BlocProvider(
                create: (_) => settingsCubit,
              ),
              BlocProvider.value(
                value: favoriteTagBloc..add(const FavoriteTagFetched()),
              ),
              BlocProvider(
                create: (context) =>
                    ThemeBloc(initialTheme: settings.themeMode),
              ),
              BlocProvider.value(value: manageBooruUserBloc),
              if (isAndroid() || isIOS())
                BlocProvider(
                  create: (context) => DeviceStoragePermissionBloc(
                    deviceInfo: deviceInfo,
                    initialStatus: PermissionStatus.denied,
                  )..add(DeviceStoragePermissionFetched()),
                ),
            ],
            child: MultiBlocListener(
              listeners: [
                BlocListener<SettingsCubit, SettingsState>(
                  listenWhen: (previous, current) =>
                      previous.settings.themeMode != current.settings.themeMode,
                  listener: (context, state) {
                    context.read<ThemeBloc>().add(ThemeChanged(
                          theme: state.settings.themeMode,
                        ));
                  },
                ),
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

Future<void> _localNotificatonHandler(NotificationResponse response) async {
  if (response.payload == null) return;
  if (isIOS()) {
    //TODO: update usage for iOS
    final uri = Uri.parse('photos-redirect://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  } else if (isAndroid()) {
    final intent = AndroidIntent(
      action: 'action_view',
      type: 'image/*',
      //TODO: download path is hard-coded
      data: Uri.parse('/storage/emulated/0/Pictures/${response.payload}')
          .toString(),
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }
}

class DioProvider {
  DioProvider(this.dir, this.generator);

  final Directory dir;
  final UserAgentGenerator generator;

  Dio getDio(String baseUrl) => dio(dir, baseUrl, generator);
}
