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
import 'package:sentry_flutter/sentry_flutter.dart';
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
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/explore/hot_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/download/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';
import 'package:boorusama/boorus/danbooru/infra/configs/danbooru/config.dart';
import 'package:boorusama/boorus/danbooru/infra/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/wiki/wiki_cacher.dart';
import 'package:boorusama/boorus/danbooru/infra/services/download_service.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/application/networking/networking.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infra/caching/fifo_cacher.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'app.dart';
import 'boorus/danbooru/application/favorites/favorites.dart';
import 'boorus/danbooru/application/home/tag_list.dart';
import 'boorus/danbooru/domain/settings/settings.dart';
import 'boorus/danbooru/infra/local/repositories/search_history/search_history.dart';
import 'boorus/danbooru/infra/repositories/repositories.dart';

import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart'
    hide PoolCategory;

//TODO: should parse from translation files instead of hardcoding
const supportedLocales = [
  Locale('en', ''),
  Locale('vi', ''),
];

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

  final settingRepository = SettingRepository(
    Hive.openBox('settings'),
    Settings.defaultSettings,
  );

  final settings = await settingRepository.load();

  final accountBox = Hive.openBox('accounts');
  final accountRepo = AccountRepository(accountBox);

  final searchHistoryBox =
      await Hive.openBox<SearchHistoryHiveObject>('search_history');
  final searchHistoryRepo = SearchHistoryRepository(
    db: searchHistoryBox,
  );

  final autocompleteBox = await Hive.openBox<String>('autocomplete');
  final autocompleteHttpCacher = AutocompleteHttpCacher(box: autocompleteBox);

  final config = DanbooruConfig();
  final booruFactory = BooruFactory.from(await loadBooruList());
  final packageInfo = PackageInfoProvider(await getPackageInfo());
  final appInfo = AppInfoProvider(await getAppInfo());
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  final defaultBooru = booruFactory.create(isSafeMode: settings.safeMode);

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

  void run() {
    runApp(
      EasyLocalization(
        useOnlyLangCode: true,
        supportedLocales: supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('en', ''),
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: packageInfo),
            RepositoryProvider.value(value: appInfo),
            RepositoryProvider.value(value: deviceInfo),
            RepositoryProvider.value(value: tagInfo),
            RepositoryProvider<IDownloadService>.value(value: downloader),
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

                  final popularSearchRepo = PopularSearchRepository(
                      accountRepository: accountRepo, api: api);

                  final tagRepo = TagRepository(api, accountRepo);

                  final artistRepo = ArtistRepository(api: api);

                  final profileRepo = ProfileRepository(
                      accountRepository: accountRepo, api: api);

                  final postRepo = PostRepository(api, accountRepo);

                  final commentRepo = CommentRepository(api, accountRepo);

                  final userRepo = UserRepository(
                      api, accountRepo, tagInfo.defaultBlacklistedTags);

                  final noteRepo = NoteRepository(api);

                  final favoriteRepo = FavoritePostRepository(api, accountRepo);

                  final artistCommentaryRepo = ArtistCommentaryCacher(
                    cache: LruCacher(capacity: 200),
                    repo: ArtistCommentaryRepository(api, accountRepo),
                  );

                  final poolRepo = PoolRepository(api, accountRepo);

                  final blacklistedTagRepo =
                      BlacklistedTagsRepository(userRepo, accountRepo);

                  final autocompleteRepo = AutocompleteCacheRepository(
                    cacher: LruCacher<String, List<AutocompleteData>>(
                      capacity: 10,
                    ),
                    repo: AutocompleteRepository(
                      api: api,
                      accountRepository: accountRepo,
                      cache: autocompleteHttpCacher,
                    ),
                  );

                  final relatedTagRepo = RelatedTagApiRepository(api);

                  final commentVoteRepo =
                      CommentVoteApiRepository(api, accountRepo);

                  final wikiRepo = WikiRepository(api);

                  final poolDescriptionRepo = PoolDescriptionRepository(
                    dio: state.dio,
                    endpoint: state.dio.options.baseUrl,
                  );

                  final postVoteRepo =
                      PostVoteApiRepository(api: api, accountRepo: accountRepo);

                  final favoritedCubit =
                      FavoritesCubit(postRepository: postRepo);
                  final popularSearchCubit =
                      SearchKeywordCubit(popularSearchRepo)..getTags();
                  final profileCubit =
                      ProfileCubit(profileRepository: profileRepo);
                  final commentBloc = CommentBloc(
                    commentVoteRepository: commentVoteRepo,
                    commentRepository: commentRepo,
                    accountRepository: accountRepo,
                  );
                  final artistCommentaryBloc = ArtistCommentaryBloc(
                      artistCommentaryRepository: artistCommentaryRepo);
                  final accountCubit =
                      AccountCubit(accountRepository: accountRepo)
                        ..getCurrentAccount();
                  final authenticationCubit = AuthenticationCubit(
                    accountRepository: accountRepo,
                    profileRepository: profileRepo,
                  )..logIn();
                  final blacklistedTagsBloc = BlacklistedTagsBloc(
                      accountRepository: accountRepo,
                      blacklistedTagsRepository: blacklistedTagRepo);
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

                  final recommendArtistCubit = RecommendedArtistPostCubit(
                    postRepository: RecommendedPostCacher(
                      cache: LruCacher(capacity: 500),
                      postRepository: postRepo,
                    ),
                  );

                  final recommendedCharaCubit = RecommendedCharacterPostCubit(
                    postRepository: RecommendedPostCacher(
                      cache: FifoCacher(capacity: 500),
                      postRepository: postRepo,
                    ),
                  );

                  final poolFromIdBloc = PoolFromPostIdBloc(
                    poolRepository: PoolFromPostCacher(
                      cache: LruCacher(capacity: 500),
                      poolRepository: poolRepo,
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
                        cache: LruCacher(capacity: 200), repo: wikiRepo),
                  );

                  final noteBloc = NoteBloc(
                      noteRepository: NoteCacher(
                    cache: LruCacher(capacity: 100),
                    repo: noteRepo,
                  ));

                  final poolDescriptionBloc = PoolDescriptionBloc(
                    endpoint: state.dio.options.baseUrl,
                    poolDescriptionRepository: PoolDescriptionCacher(
                      cache: LruCacher(capacity: 100),
                      repo: poolDescriptionRepo,
                    ),
                  );

                  return MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider<ITagRepository>.value(value: tagRepo),
                      RepositoryProvider<IProfileRepository>.value(
                          value: profileRepo),
                      RepositoryProvider<IFavoritePostRepository>.value(
                          value: favoriteRepo),
                      RepositoryProvider<IAccountRepository>.value(
                          value: accountRepo),
                      RepositoryProvider<ISettingRepository>.value(
                          value: settingRepository),
                      RepositoryProvider<INoteRepository>.value(
                          value: noteRepo),
                      RepositoryProvider<IPostRepository>.value(
                          value: postRepo),
                      RepositoryProvider<ISearchHistoryRepository>.value(
                          value: searchHistoryRepo),
                      RepositoryProvider<IConfig>.value(value: config),
                      RepositoryProvider<PoolRepository>.value(value: poolRepo),
                      RepositoryProvider<IUserRepository>.value(
                          value: userRepo),
                      RepositoryProvider<BlacklistedTagsRepository>.value(
                          value: blacklistedTagRepo),
                      RepositoryProvider<IArtistRepository>.value(
                          value: artistRepo),
                      RepositoryProvider<AutocompleteRepository>.value(
                          value: autocompleteRepo),
                      RepositoryProvider<RelatedTagRepository>.value(
                          value: relatedTagRepo),
                      RepositoryProvider<IWikiRepository>.value(
                          value: wikiRepo),
                      RepositoryProvider<IArtistCommentaryRepository>.value(
                          value: artistCommentaryRepo),
                      RepositoryProvider<PostVoteRepository>.value(
                          value: postVoteRepo),
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
                                ThemeBloc(initialTheme: settings.themeMode)),
                        BlocProvider.value(value: poolOverviewBloc),
                        BlocProvider.value(value: tagBloc),
                        BlocProvider.value(value: recommendArtistCubit),
                        BlocProvider.value(value: recommendedCharaCubit),
                        BlocProvider.value(value: poolFromIdBloc),
                        BlocProvider.value(value: artistBloc),
                        BlocProvider.value(value: wikiBloc),
                        BlocProvider.value(value: noteBloc),
                        BlocProvider.value(value: poolDescriptionBloc),
                      ],
                      child: MultiBlocListener(
                        listeners: [
                          BlocListener<AuthenticationCubit,
                              AuthenticationState>(
                            listener: (context, state) {
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
                                  theme: state.settings.themeMode));
                            },
                          ),
                        ],
                        child: BlocBuilder<BlacklistedTagsBloc,
                            BlacklistedTagsState>(
                          buildWhen: (previous, current) =>
                              current.status == LoadStatus.success &&
                              previous.blacklistedTags !=
                                  current.blacklistedTags,
                          builder: (context, state) {
                            final mostViewedCubit = MostViewedCubit(
                              postRepository: postRepo,
                              blacklistedTagsRepository: blacklistedTagRepo,
                            )..getMostViewed();
                            final popularCubit = PopularCubit(
                              postRepository: postRepo,
                              blacklistedTagsRepository: blacklistedTagRepo,
                            )..getPopular();
                            final curatedCubit = CuratedCubit(
                              postRepository: postRepo,
                              blacklistedTagsRepository: blacklistedTagRepo,
                            )..getCurated();
                            final hotCubit = HotCubit(
                              postRepository: postRepo,
                              blacklistedTagsRepository: blacklistedTagRepo,
                            )..getHot();
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: mostViewedCubit),
                                BlocProvider.value(value: popularCubit),
                                BlocProvider.value(value: curatedCubit),
                                BlocProvider.value(value: hotCubit),
                              ],
                              child: const App(),
                            );
                          },
                        ),
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
      await SentryFlutter.init(
        (options) {
          options
            ..dsn =
                'https://5aebc96ddd7e45d6af7d4e5092884ce3@o1274685.ingest.sentry.io/6469740'
            ..tracesSampleRate = 0.8;
        },
        appRunner: run,
      );
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
