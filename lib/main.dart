// Dart imports:
import 'dart:io';

// Flutter imports:

import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/artists/artist_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/profile/profile_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'app.dart';
import 'boorus/danbooru/application/comment/comment_cubit.dart';
import 'boorus/danbooru/application/home/lastest/tag_list.dart';
import 'boorus/danbooru/application/settings/settings.dart';
import 'boorus/danbooru/domain/posts/i_post_repository.dart';
import 'boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'boorus/danbooru/infrastructure/repositories/posts/black_listed_filter_decorator.dart';
import 'boorus/danbooru/infrastructure/repositories/posts/no_image_filter_decorator.dart';

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

  final apiUrl = "https://safebooru.donmai.us/";
  final api = DanbooruApi(Dio(), baseUrl: apiUrl);

  final popularSearchRepo =
      PopularSearchRepository(accountRepository: accountRepo, api: api);

  final tagRepo = TagRepository(api, accountRepo);

  final artistRepo = ArtistRepository(api: api);

  final profileRepo =
      ProfileRepository(accountRepository: accountRepo, api: api);

  final favoritesRepo = FavoritePostRepository(api, accountRepo);

  final postRepo = PostRepository(api, accountRepo, favoritesRepo);

  final commentRepo = CommentRepository(api, accountRepo);

  final userRepo = UserRepository(api, accountRepo);

  final favoriteRepo = FavoritePostRepository(api, accountRepo);

  final downloader = DownloadService();

  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await downloader.init();
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        settingsNotifier.overrideWithProvider(
          StateNotifierProvider<SettingsStateNotifier>(
            (ref) => SettingsStateNotifier(
              settingRepository: settingRepository,
              setting: SettingsState(settings: settings),
            ),
          ),
        ),
        authenticationStateNotifierProvider.overrideWithProvider(
            StateNotifierProvider<AuthenticationNotifier>((ref) {
          return AuthenticationNotifier(ref, profileRepo);
        })),
        postProvider.overrideWithProvider(Provider<IPostRepository>((ref) {
          final filteredPostRepo = BlackListedFilterDecorator(
            postRepository: postRepo,
            settings: ref.watch(settingsNotifier.state).settings,
          );
          final removedNullImageRepo =
              NoImageFilterDecorator(postRepository: filteredPostRepo);
          return removedNullImageRepo;
        })),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ITagRepository>(create: (_) => tagRepo),
          RepositoryProvider<IProfileRepository>(create: (_) => profileRepo),
          RepositoryProvider<IFavoritePostRepository>(
              create: (_) => favoriteRepo),
          RepositoryProvider<IAccountRepository>(create: (_) => accountRepo),
          RepositoryProvider<IDownloadService>(create: (_) => downloader),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SearchKeywordCubit(popularSearchRepo)),
            BlocProvider(
                create: (_) => ArtistCubit(artistRepository: artistRepo)),
            BlocProvider(
                create: (_) => FavoritesCubit(postRepository: postRepo)),
            BlocProvider(
                create: (_) => ProfileCubit(profileRepository: profileRepo)),
            BlocProvider(
              create: (context) => CommentCubit(
                commentRepository: commentRepo,
                userRepository: userRepo,
              ),
            ),
          ],
          child: EasyLocalization(
            useOnlyLangCode: true,
            supportedLocales: [Locale('en', ''), Locale('vi', '')],
            path: 'assets/translations',
            fallbackLocale: Locale('en', ''),
            child: App(),
          ),
        ),
      ),
    ),
  );
}
