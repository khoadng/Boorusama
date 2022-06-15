// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/account/account_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/curated_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/most_viewed_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/popular_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/networking/network_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/user/user_blacklisted_tags_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/i_artist_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_note_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/danbooru/config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/local/repositories/search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/artists/artist_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/note_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/profile/profile_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'app.dart';
import 'boorus/danbooru/application/artist_commentary/artist_commentary_cubit.dart';
import 'boorus/danbooru/application/comment/comment_cubit.dart';
import 'boorus/danbooru/application/home/lastest/tag_list.dart';
import 'boorus/danbooru/application/settings/settings.dart';
import 'boorus/danbooru/domain/accounts/account.dart';
import 'boorus/danbooru/domain/posts/i_post_repository.dart';
import 'boorus/danbooru/infrastructure/repositories/posts/artist_commentary_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await FlutterDownloader.initialize(debug: false);
    }
  }

  await EasyLocalization.ensureInitialized();

  if (!kIsWeb) {
    final dbDirectory = await getApplicationDocumentsDirectory();

    Hive.init(dbDirectory.path);
  }

  final settingRepository = SettingRepository(
    Hive.openBox('settings'),
    Settings.defaultSettings,
  );

  final List<String> defaultBlacklistedTags = [
    'guro',
    'scat',
    'furry -rating:s'
  ];

  final settings = await settingRepository.load();

  final accountBox = Hive.openBox('accounts');
  final accountRepo = AccountRepository(accountBox);

  final downloader = DownloadService();
  final searchHistoryRepo =
      SearchHistoryRepository(settingRepository: settingRepository);

  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await downloader.init();
    }
  }

  final config = DanbooruConfig();
  final packageInfo = PackageInfoProvider(await getPackageInfo());

  void run() {
    runApp(
      EasyLocalization(
        useOnlyLangCode: true,
        supportedLocales: const [Locale('en', ''), Locale('vi', '')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', ''),
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: packageInfo),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => NetworkBloc()),
              BlocProvider(
                create: (_) => ApiCubit(
                  defaultUrl: getBooru(settings.safeMode).url,
                ),
              ),
              BlocProvider(
                  create: (_) => ApiEndpointCubit(
                      initialValue: getBooru(settings.safeMode))),
              BlocProvider(
                  create: (_) => SettingsCubit(
                      settingRepository: settingRepository,
                      settings: settings)),
            ],
            child: MultiBlocListener(
              listeners: [
                BlocListener<SettingsCubit, SettingsState>(
                  listenWhen: (previous, current) =>
                      previous.settings.safeMode != current.settings.safeMode,
                  listener: (context, state) {
                    context
                        .read<ApiEndpointCubit>()
                        .changeApi(state.settings.safeMode);
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

                  final userRepo =
                      UserRepository(api, accountRepo, defaultBlacklistedTags);

                  final nopeRepo = NoteRepository(api);

                  final favoriteRepo = FavoritePostRepository(api, accountRepo);

                  final artistCommentaryRepo =
                      ArtistCommentaryRepository(api, accountRepo);

                  final poolRepo = PoolRepository(api, accountRepo);

                  final blacklistedTagRepo =
                      BlacklistedTagsRepository(userRepo, accountRepo);

                  final favoritedCubit =
                      FavoritesCubit(postRepository: postRepo);
                  final popularSearchCubit =
                      SearchKeywordCubit(popularSearchRepo)..getTags();
                  final profileCubit =
                      ProfileCubit(profileRepository: profileRepo);
                  final commentCubit = CommentCubit(
                      commentRepository: commentRepo, userRepository: userRepo);
                  final artistCommentaryCubit = ArtistCommentaryCubit(
                      artistCommentaryRepository: artistCommentaryRepo);
                  final accountCubit =
                      AccountCubit(accountRepository: accountRepo)
                        ..getCurrentAccount();
                  final authenticationCubit = AuthenticationCubit(
                    accountRepository: accountRepo,
                    profileRepository: profileRepo,
                  )..logIn();
                  final poolCubit = PoolCubit(
                      poolRepository: poolRepo, postRepository: postRepo);
                  final userBlacklistedTagsBloc = UserBlacklistedTagsBloc(
                      userRepository: userRepo,
                      blacklistedTagsRepository: blacklistedTagRepo);

                  return MultiRepositoryProvider(
                      providers: [
                        RepositoryProvider<ITagRepository>.value(
                            value: tagRepo),
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
                        RepositoryProvider<PoolRepository>.value(
                            value: poolRepo),
                        RepositoryProvider<IUserRepository>.value(
                            value: userRepo),
                        RepositoryProvider<BlacklistedTagsRepository>.value(
                            value: blacklistedTagRepo),
                        RepositoryProvider<IArtistRepository>.value(
                            value: artistRepo),
                      ],
                      child: MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: popularSearchCubit),
                          BlocProvider.value(value: favoritedCubit),
                          BlocProvider.value(value: profileCubit),
                          BlocProvider.value(value: commentCubit),
                          BlocProvider.value(value: artistCommentaryCubit),
                          BlocProvider.value(value: accountCubit),
                          BlocProvider.value(value: authenticationCubit),
                          BlocProvider.value(value: poolCubit),
                          BlocProvider.value(value: userBlacklistedTagsBloc),
                          BlocProvider(
                              create: (context) =>
                                  ThemeBloc(initialTheme: settings.themeMode))
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
                                }
                              },
                            ),
                            BlocListener<UserBlacklistedTagsBloc,
                                UserBlacklistedTagsState>(
                              listenWhen: (previous, current) =>
                                  current.blacklistedTags !=
                                  previous.blacklistedTags,
                              listener: (context, state) {
                                blacklistedTagRepo
                                    ._refresh(state.blacklistedTags);
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
                          child: BlocBuilder<UserBlacklistedTagsBloc,
                              UserBlacklistedTagsState>(
                            buildWhen: (previous, current) =>
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
                      ));
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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SentryFlutter.init(
      (options) {
        options
          ..dsn =
              'https://5aebc96ddd7e45d6af7d4e5092884ce3@o1274685.ingest.sentry.io/6469740'
          ..tracesSampleRate = 0.9;
      },
      appRunner: run,
    );
  }
}

class PackageInfoProvider {
  PackageInfoProvider(this.packageInfo);

  final PackageInfo packageInfo;

  PackageInfo getPackageInfo() => packageInfo;
}

Future<PackageInfo> getPackageInfo() => PackageInfo.fromPlatform();

class BlacklistedTagsRepository {
  BlacklistedTagsRepository(this.userRepository, this.accountRepository);
  final IUserRepository userRepository;
  final IAccountRepository accountRepository;
  List<String>? _tags;

  Future<List<String>> getBlacklistedTags() async {
    // ignore: prefer_conditional_assignment
    if (_tags == null) {
      final account = await accountRepository.get();
      if (account == Account.empty) {
        return [];
      }
      _tags ??= await userRepository
          .getUserById(account.id)
          .then((value) => value.blacklistedTags);
    }
    return _tags!;
  }

  Future<void> _refresh(List<String> tags) async {
    _tags = tags;
  }
}
