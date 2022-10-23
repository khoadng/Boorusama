// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/booru_factory.dart';
import 'package:boorusama/boorus/danbooru/application/account/account.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist_cacher.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist_commentary_cacher.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles/profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/setting_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/services/download_service_flutter_downloader.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/download/download_service.dart';
import 'package:boorusama/core/application/networking/networking.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/sentry.dart';
import 'app.dart';
import 'boorus/danbooru/application/favorites/favorites.dart';
import 'boorus/danbooru/application/tag/most_searched_tag_cubit.dart';
import 'boorus/danbooru/domain/settings/settings.dart';
import 'boorus/danbooru/infra/local/repositories/search_history/search_history.dart';
import 'boorus/danbooru/infra/repositories/repositories.dart';

//TODO: should parse from translation files instead of hardcoding
const supportedLocales = [
  Locale('en', ''),
  Locale('vi', ''),
  Locale('ru', ''),
  Locale('be', ''),
];

const cheatsheetUrl = 'https://safebooru.donmai.us/wiki_pages/help:cheatsheet';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fileNameGenerator = PostFileNameGenerator();

  await EasyLocalization.ensureInitialized();

  if (!isWeb()) {
    final dbDirectory = await getApplicationDocumentsDirectory();

    Hive
      ..init(dbDirectory.path)
      ..registerAdapter(SearchHistoryHiveObjectAdapter());
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

  final settingRepository = SettingRepositoryHive(
    Hive.openBox('settings'),
    Settings.defaultSettings,
  );

  final settings = await settingRepository.load();

  final accountBox = Hive.openBox('accounts');
  final accountRepo = AccountRepositoryApi(accountBox);

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

  final booruFactory = BooruFactory.from(await loadBooruList());
  final packageInfo = PackageInfoProvider(await getPackageInfo());
  final appInfo = AppInfoProvider(await getAppInfo());
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  final defaultBooru = booruFactory.create(isSafeMode: settings.safeMode);

  final tempPath = await getTemporaryDirectory();

  //TODO: this notification is only used for download feature
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _localNotificatonHandler,
  );

  final downloader = await createDownloader(
    settings.downloadMethod,
    fileNameGenerator,
    deviceInfo,
    flutterLocalNotificationsPlugin,
  );

  //TODO: shouldn't hardcode language.
  setLocaleMessages('vi', ViMessages());
  setLocaleMessages('ru', RuMessages());
  setLocaleMessages('be', RuMessages());

  void run() {
    runApp(
      EasyLocalization(
        useOnlyLangCode: true,
        supportedLocales: supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('en', ''),
        useFallbackTranslations: true,
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: packageInfo),
            RepositoryProvider.value(value: appInfo),
            RepositoryProvider.value(value: deviceInfo),
            RepositoryProvider.value(value: tagInfo),
            RepositoryProvider<DownloadService>.value(value: downloader),
            RepositoryProvider<DownloadService<Post>>.value(value: downloader),
            RepositoryProvider.value(value: userMetatagRepo),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => NetworkBloc(),
                lazy: false,
              ),
              BlocProvider(
                create: (_) => ApiCubit(
                  defaultUrl: defaultBooru.url,
                  onDioRequest: (baseUrl) => dio(tempPath, baseUrl),
                ),
              ),
              BlocProvider(
                create: (_) => ApiEndpointCubit(
                  factory: booruFactory,
                  initialValue: defaultBooru,
                ),
              ),
              BlocProvider(
                create: (_) => SettingsCubit(
                  settingRepository: settingRepository,
                  settings: settings,
                ),
              ),
            ],
            child: MultiBlocListener(
              listeners: [
                BlocListener<SettingsCubit, SettingsState>(
                  listenWhen: (previous, current) =>
                      previous.settings.safeMode != current.settings.safeMode,
                  listener: (context, state) {
                    context
                        .read<ApiEndpointCubit>()
                        .changeApi(isSafeMode: state.settings.safeMode);
                  },
                ),
                BlocListener<ApiEndpointCubit, ApiEndpointState>(
                  listener: (context, state) =>
                      context.read<ApiCubit>().changeApi(state.booru),
                ),
              ],
              child: BlocBuilder<ApiCubit, ApiState>(
                builder: (context, state) {
                  final api = state.api;

                  final popularSearchRepo = PopularSearchRepositoryApi(
                    accountRepository: accountRepo,
                    api: api,
                  );

                  final tagRepo = TagRepositoryApi(api, accountRepo);

                  final artistRepo = ArtistRepositoryApi(api: api);

                  final profileRepo = ProfileRepositoryApi(
                    accountRepository: accountRepo,
                    api: api,
                  );

                  final postRepo = PostRepositoryApi(api, accountRepo);

                  final commentRepo = CommentRepositoryApi(api, accountRepo);

                  final userRepo = UserRepositoryApi(
                    api,
                    accountRepo,
                    tagInfo.defaultBlacklistedTags,
                  );

                  final noteRepo = NoteRepositoryApi(api);

                  final favoriteRepo =
                      FavoritePostRepositoryApi(api, accountRepo);

                  final artistCommentaryRepo = ArtistCommentaryCacher(
                    cache: LruCacher(capacity: 200),
                    repo: ArtistCommentaryRepositoryApi(api, accountRepo),
                  );

                  final poolRepo = PoolRepositoryApi(api, accountRepo);

                  final blacklistedTagRepo =
                      BlacklistedTagsRepository(userRepo, accountRepo);

                  final autocompleteRepo = AutocompleteRepositoryApi(
                    api: api,
                    accountRepository: accountRepo,
                  );

                  final relatedTagRepo = RelatedTagRepositoryApi(api);

                  final commentVoteRepo =
                      CommentVoteApiRepository(api, accountRepo);

                  final wikiRepo = WikiRepositoryApi(api);

                  final poolDescriptionRepo = PoolDescriptionRepositoryApi(
                    dio: state.dio,
                    endpoint: state.dio.options.baseUrl,
                  );

                  final postVoteRepo = PostVoteApiRepositoryApi(
                    api: api,
                    accountRepo: accountRepo,
                  );

                  final favoritedCubit =
                      FavoritesCubit(postRepository: postRepo);
                  final popularSearchCubit = SearchKeywordCubit(
                    popularSearchRepo,
                    settings.safeMode ? tagInfo.r18Tags.toSet() : {},
                  )..getTags();
                  final profileCubit =
                      ProfileCubit(profileRepository: profileRepo);
                  final commentBloc = CommentBloc(
                    commentVoteRepository: commentVoteRepo,
                    commentRepository: commentRepo,
                    accountRepository: accountRepo,
                  );
                  final artistCommentaryBloc = ArtistCommentaryBloc(
                    artistCommentaryRepository: artistCommentaryRepo,
                  );
                  final accountCubit =
                      AccountCubit(accountRepository: accountRepo)
                        ..getCurrentAccount();
                  final authenticationCubit = AuthenticationCubit(
                    accountRepository: accountRepo,
                    profileRepository: profileRepo,
                  )..logIn();
                  final blacklistedTagsBloc = BlacklistedTagsBloc(
                    accountRepository: accountRepo,
                    blacklistedTagsRepository: blacklistedTagRepo,
                  );
                  final poolOverviewBloc = PoolOverviewBloc()
                    ..add(const PoolOverviewChanged(
                      category: PoolCategory.series,
                      order: PoolOrder.latest,
                    ));

                  final tagBloc = TagBloc(
                    tagRepository: TagCacher(
                      cache: LruCacher(capacity: 1000),
                      repo: tagRepo,
                    ),
                  );

                  final artistBloc = ArtistBloc(
                    artistRepository: ArtistCacher(
                      repo: artistRepo,
                      cache: LruCacher(capacity: 100),
                    ),
                  );

                  final wikiBloc = WikiBloc(
                    wikiRepository: WikiCacher(
                      cache: LruCacher(capacity: 200),
                      repo: wikiRepo,
                    ),
                  );

                  final noteBloc = NoteBloc(
                    noteRepository: NoteCacher(
                      cache: LruCacher(capacity: 100),
                      repo: noteRepo,
                    ),
                  );

                  return MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider<TagRepository>.value(value: tagRepo),
                      RepositoryProvider<ProfileRepository>.value(
                        value: profileRepo,
                      ),
                      RepositoryProvider<FavoritePostRepository>.value(
                        value: favoriteRepo,
                      ),
                      RepositoryProvider<AccountRepository>.value(
                        value: accountRepo,
                      ),
                      RepositoryProvider<SettingRepository>.value(
                        value: settingRepository,
                      ),
                      RepositoryProvider<NoteRepository>.value(value: noteRepo),
                      RepositoryProvider<PostRepository>.value(value: postRepo),
                      RepositoryProvider<SearchHistoryRepository>.value(
                        value: searchHistoryRepo,
                      ),
                      RepositoryProvider<PoolRepository>.value(value: poolRepo),
                      RepositoryProvider<UserRepository>.value(value: userRepo),
                      RepositoryProvider<BlacklistedTagsRepository>.value(
                        value: blacklistedTagRepo,
                      ),
                      RepositoryProvider<ArtistRepository>.value(
                        value: artistRepo,
                      ),
                      RepositoryProvider<AutocompleteRepository>.value(
                        value: autocompleteRepo,
                      ),
                      RepositoryProvider<RelatedTagRepository>.value(
                        value: relatedTagRepo,
                      ),
                      RepositoryProvider<WikiRepository>.value(value: wikiRepo),
                      RepositoryProvider<ArtistCommentaryRepository>.value(
                        value: artistCommentaryRepo,
                      ),
                      RepositoryProvider<PostVoteRepository>.value(
                        value: postVoteRepo,
                      ),
                      RepositoryProvider<PoolDescriptionRepository>.value(
                        value: poolDescriptionRepo,
                      ),
                    ],
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: popularSearchCubit),
                        BlocProvider.value(value: favoritedCubit),
                        BlocProvider.value(value: profileCubit),
                        BlocProvider.value(value: commentBloc),
                        BlocProvider.value(value: artistCommentaryBloc),
                        BlocProvider.value(value: accountCubit),
                        BlocProvider.value(value: authenticationCubit),
                        BlocProvider.value(value: blacklistedTagsBloc),
                        BlocProvider(
                          create: (context) =>
                              ThemeBloc(initialTheme: settings.themeMode),
                        ),
                        BlocProvider.value(value: poolOverviewBloc),
                        BlocProvider.value(value: tagBloc),
                        BlocProvider.value(value: artistBloc),
                        BlocProvider.value(value: wikiBloc),
                        BlocProvider.value(value: noteBloc),
                      ],
                      child: MultiBlocListener(
                        listeners: [
                          BlocListener<AuthenticationCubit,
                              AuthenticationState>(
                            listener: (context, state) {
                              //TODO: login from settings is bugged, it shouldn't be handled together with login flow.
                              if (state is Authenticated) {
                                accountCubit.setAccount(state.account);
                              } else if (state is Unauthenticated) {
                                accountCubit.removeAccount();
                                blacklistedTagRepo.clearCache();
                              }
                            },
                          ),
                          BlocListener<SettingsCubit, SettingsState>(
                            listenWhen: (previous, current) =>
                                previous.settings.themeMode !=
                                current.settings.themeMode,
                            listener: (context, state) {
                              context.read<ThemeBloc>().add(ThemeChanged(
                                    theme: state.settings.themeMode,
                                  ));
                            },
                          ),
                        ],
                        child: const App(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  if (kDebugMode) {
    run();
  } else {
    if (settings.dataCollectingStatus == DataCollectingStatus.allow) {
      await runWithSentry(run);
    } else {
      run();
    }
  }
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
