// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/account/account_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/curated_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/most_viewed_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/popular_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/networking/network_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_note_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/danbooru/config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/local/repositories/search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/artists/artist_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
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
import 'boorus/danbooru/domain/posts/i_post_repository.dart';
import 'boorus/danbooru/infrastructure/repositories/posts/artist_commentary_repository.dart';

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
    Hive.openBox("settings"),
    Settings.defaultSettings,
  );

  final settings = await settingRepository.load();

  final accountBox = Hive.openBox("accounts");
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

  runApp(
    EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: [Locale('en', ''), Locale('vi', '')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', ''),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NetworkBloc()),
          BlocProvider(
            create: (_) => ApiCubit(
              defaultUrl: "https://safebooru.donmai.us/",
            ),
          ),
          BlocProvider(create: (_) => ApiEndpointCubit()),
          BlocProvider(
              create: (_) => SettingsCubit(settingRepository: settingRepository)
                ..update(settings)),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<SettingsCubit, SettingsState>(
              listenWhen: (previous, current) =>
                  previous.settings != current.settings,
              listener: (context, state) {
                ReadContext(context)
                    .read<ApiEndpointCubit>()
                    .changeApi(state.settings.safeMode);
              },
            ),
            BlocListener<ApiEndpointCubit, ApiEndpointState>(
              listenWhen: (previous, current) => previous != current,
              listener: (context, state) =>
                  ReadContext(context).read<ApiCubit>().changeApi(state.booru),
            ),
          ],
          child: BlocBuilder<ApiCubit, ApiState>(
            builder: (context, state) {
              final api = state.api;

              final popularSearchRepo = PopularSearchRepository(
                  accountRepository: accountRepo, api: api);

              final tagRepo = TagRepository(api, accountRepo);

              final artistRepo = ArtistRepository(api: api);

              final profileRepo =
                  ProfileRepository(accountRepository: accountRepo, api: api);

              final favoritesRepo = FavoritePostRepository(api, accountRepo);

              final postRepo = PostRepository(api, accountRepo, favoritesRepo);

              final commentRepo = CommentRepository(api, accountRepo);

              final userRepo = UserRepository(api, accountRepo);

              final nopeRepo = NoteRepository(api);

              final favoriteRepo = FavoritePostRepository(api, accountRepo);

              final artistCommentaryRepo =
                  ArtistCommentaryRepository(api, accountRepo);

              final mostViewedCubit = MostViewedCubit(postRepository: postRepo)
                ..getMostViewed();
              final popularCubit = PopularCubit(postRepository: postRepo)
                ..getPopular();
              final curatedCubit = CuratedCubit(postRepository: postRepo)
                ..getCurated();

              final favoritedCubit = FavoritesCubit(postRepository: postRepo);
              final artistCubit = ArtistCubit(artistRepository: artistRepo);
              final popularSearchCubit = SearchKeywordCubit(popularSearchRepo);
              final profileCubit = ProfileCubit(profileRepository: profileRepo);
              final commentCubit = CommentCubit(
                  commentRepository: commentRepo, userRepository: userRepo);
              final artistCommentaryCubit = ArtistCommentaryCubit(
                  artistCommentaryRepository: artistCommentaryRepo);
              final accountCubit = AccountCubit(accountRepository: accountRepo)
                ..getCurrentAccount();
              final authenticationCubit = AuthenticationCubit(
                accountRepository: accountRepo,
                profileRepository: profileRepo,
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
                  RepositoryProvider<IDownloadService>.value(value: downloader),
                  RepositoryProvider<ISettingRepository>.value(
                      value: settingRepository),
                  RepositoryProvider<INoteRepository>.value(value: nopeRepo),
                  RepositoryProvider<IPostRepository>.value(value: postRepo),
                  RepositoryProvider<ISearchHistoryRepository>.value(
                      value: searchHistoryRepo),
                  RepositoryProvider<IConfig>.value(value: config),
                ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: popularSearchCubit),
                    BlocProvider.value(value: artistCubit),
                    BlocProvider.value(value: favoritedCubit),
                    BlocProvider.value(value: profileCubit),
                    BlocProvider.value(value: commentCubit),
                    BlocProvider.value(value: artistCommentaryCubit),
                    BlocProvider.value(value: mostViewedCubit),
                    BlocProvider.value(value: popularCubit),
                    BlocProvider.value(value: curatedCubit),
                    BlocProvider.value(value: accountCubit),
                    BlocProvider.value(value: authenticationCubit),
                  ],
                  child: BlocListener<AuthenticationCubit, AuthenticationState>(
                    listener: (context, state) {
                      if (state is Authenticated) {
                        accountCubit.setAccount(state.account);
                      } else if (state is Unauthenticated) {
                        accountCubit.removeAccount();
                      }
                    },
                    child: App(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
