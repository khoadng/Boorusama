// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timeago/timeago.dart';

// Project imports:
import 'package:boorusama/app_info.dart';
import 'package:boorusama/boorus/booru_factory.dart';
import 'package:boorusama/boorus/danbooru/application/account/account.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
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
import 'package:boorusama/boorus/danbooru/infrastructure/configs/danbooru/config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/local/repositories/search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/wiki/wiki_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/tag_info_service.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/application/networking/networking.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infrastructure/caching/lru_cacher.dart';
import 'package:boorusama/core/infrastructure/device_info_service.dart';
import 'app.dart';
import 'boorus/danbooru/application/favorites/favorites.dart';
import 'boorus/danbooru/application/home/tag_list.dart';
import 'boorus/danbooru/domain/settings/settings.dart';
import 'boorus/danbooru/infrastructure/repositories/repositories.dart';

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

  if (!kIsWeb) {
    final dbDirectory = await getApplicationDocumentsDirectory();

    Hive.init(dbDirectory.path);
  }

  if (isDesktopPlatform()) {
    doWhenWindowReady(() {
      const initialSize = Size(1000, 700);
      const minSize = Size(350, 700);
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

  final searchHistoryRepo =
      SearchHistoryRepository(settingRepository: settingRepository);

  final config = DanbooruConfig();
  final booruFactory = BooruFactory.from(await loadBooruList());
  final packageInfo = PackageInfoProvider(await getPackageInfo());
  final appInfo = AppInfoProvider(await getAppInfo());
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  final downloader = DownloadService(
    fileNameGenerator: fileNameGenerator,
    deviceInfo: deviceInfo,
  );

  if (isAndroid() || isIOS()) {
    await FlutterDownloader.initialize();
    await downloader.init();
  }

  final defaultBooru = booruFactory.create(isSafeMode: settings.safeMode);

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

                  final nopeRepo = NoteRepository(api);

                  final favoriteRepo = FavoritePostRepository(api, accountRepo);

                  final artistCommentaryRepo =
                      ArtistCommentaryRepository(api, accountRepo);

                  final poolRepo = PoolRepository(api, accountRepo);

                  final blacklistedTagRepo =
                      BlacklistedTagsRepository(userRepo, accountRepo);

                  final autocompleteRepo = AutocompleteCacheRepository(
                    cacher: LruCacher<String, List<AutocompleteData>>(
                      capacity: 100,
                    ),
                    repo: AutocompleteRepository(
                        api: api, accountRepository: accountRepo),
                  );

                  final relatedTagRepo = RelatedTagApiRepository(api);

                  final commentVoteRepo =
                      CommentVoteApiRepository(api, accountRepo);

                  final wikiRepo = WikiRepository(api);

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
                  final artistCommentaryCubit = ArtistCommentaryCubit(
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

                  final postBloc = PostBloc(
                    postRepository: postRepo,
                    blacklistedTagsRepository: blacklistedTagRepo,
                  )..add(const PostRefreshed());

                  return MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider<ITagRepository>.value(value: tagRepo),
                      RepositoryProvider<IProfileRepository>.value(
                          value: profileRepo),
                      RepositoryProvider<IFavoritePostRepository>.value(
                          value: favoriteRepo),
                      RepositoryProvider<IAccountRepository>.value(
                          value: accountRepo),
                      RepositoryProvider<IDownloadService>.value(
                          value: downloader),
                      RepositoryProvider<ISettingRepository>.value(
                          value: settingRepository),
                      RepositoryProvider<INoteRepository>.value(
                          value: nopeRepo),
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
                    ],
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: popularSearchCubit),
                        BlocProvider.value(value: favoritedCubit),
                        BlocProvider.value(value: profileCubit),
                        BlocProvider.value(value: commentBloc),
                        BlocProvider.value(value: artistCommentaryCubit),
                        BlocProvider.value(value: accountCubit),
                        BlocProvider.value(value: authenticationCubit),
                        BlocProvider.value(value: blacklistedTagsBloc),
                        BlocProvider(
                            create: (context) =>
                                ThemeBloc(initialTheme: settings.themeMode)),
                        BlocProvider.value(value: poolOverviewBloc),
                        BlocProvider.value(value: postBloc),
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
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: mostViewedCubit),
                                BlocProvider.value(value: popularCubit),
                                BlocProvider.value(value: curatedCubit),
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

class PackageInfoProvider {
  PackageInfoProvider(this.packageInfo);

  final PackageInfo packageInfo;

  PackageInfo getPackageInfo() => packageInfo;
}

class AppInfoProvider {
  AppInfoProvider(this.appInfo);

  final AppInfo appInfo;

  AppInfo getAppInfo() => appInfo;
}

Future<PackageInfo> getPackageInfo() => PackageInfo.fromPlatform();
