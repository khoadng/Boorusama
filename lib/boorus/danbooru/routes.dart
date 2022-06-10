// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_description_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_detail_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_from_post_id_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_note_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/accounts/login/login_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/artists/artist_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/settings_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_bloc.dart';
import 'application/note/note_bloc.dart';
import 'presentation/features/accounts/profile/profile_page.dart';
import 'presentation/features/home/home_page.dart';
import 'presentation/features/post_detail/post_image_page.dart';
import 'presentation/features/search/search_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => HomePage(),
);

final artistHandler = Handler(handlerFunc: (
  context,
  Map<String, List<String>> params,
) {
  final args = context!.settings!.arguments as List;

  return ArtistPage(
    artistName: args[0],
    backgroundImageUrl: args[1],
  );
});

final postDetailHandler = Handler(handlerFunc: (
  context,
  Map<String, List<String>> params,
) {
  final args = context!.settings!.arguments as List;
  final posts = args[0];
  final index = args[1];

  AutoScrollController? controller;
  if (args.length == 3) {
    controller = args[2];
  }

  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => SliverPostGridBloc(posts: posts)),
      BlocProvider(
        create: (context) => IsPostFavoritedCubit(
          accountRepository: RepositoryProvider.of<IAccountRepository>(context),
          favoritePostRepository:
              RepositoryProvider.of<IFavoritePostRepository>(context),
        ),
      ),
      BlocProvider(
          create: (context) => RecommendedArtistPostCubit(
              postRepository: RepositoryProvider.of<IPostRepository>(context))),
      BlocProvider(
          create: (context) => PoolFromPostIdCubit(
              poolRepository: RepositoryProvider.of<PoolRepository>(context))),
      BlocProvider(
          create: (context) => RecommendedCharacterPostCubit(
              postRepository: RepositoryProvider.of<IPostRepository>(context))),
      BlocProvider.value(value: BlocProvider.of<AuthenticationCubit>(context)),
      BlocProvider.value(value: BlocProvider.of<ApiEndpointCubit>(context)),
    ],
    child: RepositoryProvider.value(
      value: RepositoryProvider.of<ITagRepository>(context),
      child: Builder(
        builder: (context) =>
            BlocListener<SliverPostGridBloc, SliverPostGridState>(
          listenWhen: (previous, current) =>
              previous.currentIndex != current.currentIndex,
          listener: (context, state) async {
            if (controller == null) return;
            return await controller.scrollToIndex(state.currentIndex);
          },
          child: PostDetailPage(
            post: posts[index],
            intitialIndex: index,
            posts: posts,
          ),
        ),
      ),
    ),
  );
});

final postSearchHandler = Handler(handlerFunc: (
  context,
  Map<String, List<String>> params,
) {
  final args = context!.settings!.arguments as List;

  return MultiBlocProvider(
    providers: [
      BlocProvider(
          create: (context) => SearchHistoryCubit(
              searchHistoryRepository:
                  RepositoryProvider.of<ISearchHistoryRepository>(context))),
    ],
    child: SearchPage(
      initialQuery: args[0],
    ),
  );
});

final postDetailImageHandler = Handler(handlerFunc: (
  context,
  Map<String, List<String>> params,
) {
  final args = context!.settings!.arguments as List;

  return MultiBlocProvider(
    providers: [
      BlocProvider(
          create: (_) => NoteBloc(
              noteRepository: RepositoryProvider.of<INoteRepository>(context))
            ..add(NoteRequested(postId: args[0].id)))
    ],
    child: PostImagePage(
      post: args[0],
    ),
  );
});

final userHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  // final String userId = params["id"][0];

  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: BlocProvider.of<ProfileCubit>(context!)),
      BlocProvider.value(value: BlocProvider.of<FavoritesCubit>(context)),
    ],
    child: const ProfilePage(),
  );
});

final loginHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: BlocProvider.of<AuthenticationCubit>(context!)),
    ],
    child: const LoginPage(),
  );
});

final settingsHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return const SettingsPage();
});

final poolDetailHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  final args = context!.settings!.arguments as List;

  return BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
    builder: (context, state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => PoolDetailCubit(
                  postRepository:
                      RepositoryProvider.of<IPostRepository>(context))),
          BlocProvider(
              create: (context) =>
                  PoolDescriptionCubit(endpoint: state.booru.url)),
          BlocProvider(
              create: (context) => NoteBloc(
                  noteRepository:
                      RepositoryProvider.of<INoteRepository>(context))),
        ],
        child: PoolDetailPage(
          pool: args[0],
        ),
      );
    },
  );
});
