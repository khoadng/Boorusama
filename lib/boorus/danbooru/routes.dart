// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/application/user/user.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/accounts/login/login_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/artists/artist_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/settings_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/infrastructure/caching/fifo_cacher.dart';
import 'package:boorusama/main.dart';
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

  return MultiBlocProvider(
    providers: [
      BlocProvider(
          create: (context) => PostBloc(
                postRepository: RepositoryProvider.of<IPostRepository>(context),
                blacklistedTagsRepository:
                    context.read<BlacklistedTagsRepository>(),
              )..add(PostRefreshed(tag: args[0]))),
      BlocProvider(
          create: (context) =>
              ArtistCubit(artistRepository: context.read<IArtistRepository>())
                ..getArtist(args[0]))
    ],
    child: ArtistPage(
      artistName: args[0],
      backgroundImageUrl: args[1],
    ),
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
      BlocProvider(create: (context) => SliverPostGridBloc()),
      BlocProvider(
        create: (context) => IsPostFavoritedBloc(
          accountRepository: context.read<IAccountRepository>(),
          favoritePostRepository: context.read<IFavoritePostRepository>(),
        )..add(IsPostFavoritedRequested(postId: posts[index].id)),
      ),
      BlocProvider(
          create: (context) => RecommendedArtistPostCubit(
                postRepository: RecommendedPostCacher(
                  cache: FifoCacher<String, List<Post>>(capacity: 100),
                  postRepository: context.read<IPostRepository>(),
                ),
              )..add(RecommendedPostRequested(tags: posts[index].artistTags))),
      BlocProvider(
          create: (context) => PoolFromPostIdBloc(
                  poolRepository: PoolFromPostCacher(
                cache: FifoCacher<int, List<Pool>>(capacity: 100),
                poolRepository: context.read<PoolRepository>(),
              ))
                ..add(PoolFromPostIdRequested(postId: posts[index].id))),
      BlocProvider(
          create: (context) => RecommendedCharacterPostCubit(
                postRepository: RecommendedPostCacher(
                  cache: FifoCacher<String, List<Post>>(capacity: 100),
                  postRepository: context.read<IPostRepository>(),
                ),
              )..add(
                  RecommendedPostRequested(tags: posts[index].characterTags))),
      BlocProvider.value(value: BlocProvider.of<AuthenticationCubit>(context)),
      BlocProvider.value(value: BlocProvider.of<ApiEndpointCubit>(context)),
      BlocProvider.value(value: BlocProvider.of<ThemeBloc>(context)),
    ],
    child: RepositoryProvider.value(
      value: RepositoryProvider.of<ITagRepository>(context),
      child: Builder(
        builder: (context) =>
            BlocListener<SliverPostGridBloc, SliverPostGridState>(
          listenWhen: (previous, current) =>
              previous.nextIndex != current.nextIndex,
          listener: (context, state) {
            if (controller == null) return;
            controller.scrollToIndex(
              state.nextIndex,
              duration: const Duration(milliseconds: 200),
            );
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
                  context.read<ISearchHistoryRepository>())),
      BlocProvider(
          create: (context) => PostBloc(
                postRepository: context.read<IPostRepository>(),
                blacklistedTagsRepository:
                    context.read<BlacklistedTagsRepository>(),
              )),
      BlocProvider.value(value: BlocProvider.of<ThemeBloc>(context)),
      BlocProvider(
          create: (context) => TagSearchBloc(
                tagInfo: context.read<TagInfo>(),
                autocompleteRepository: context.read<AutocompleteRepository>(),
              )),
      BlocProvider(
          create: (context) => SearchBloc(
              initial: const SearchState(displayState: DisplayState.options)))
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
  final pool = args[0] as Pool;

  return BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
    builder: (context, state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => PoolDetailCubit(
                  ids: Queue.from(pool.postIds.reversed),
                  postRepository:
                      RepositoryProvider.of<IPostRepository>(context))
                ..load()),
          BlocProvider(
              create: (context) =>
                  PoolDescriptionCubit(endpoint: state.booru.url)),
          BlocProvider(
              create: (context) => NoteBloc(
                  noteRepository:
                      RepositoryProvider.of<INoteRepository>(context))),
        ],
        child: PoolDetailPage(
          pool: pool,
        ),
      );
    },
  );
});

final favoritesHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  final args = context!.settings!.arguments as List;
  final String username = args[0];

  return BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
    builder: (context, state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => PostBloc(
                    postRepository:
                        RepositoryProvider.of<IPostRepository>(context),
                    blacklistedTagsRepository:
                        context.read<BlacklistedTagsRepository>(),
                  )..add(PostRefreshed(tag: 'ordfav:$username'))),
        ],
        child: FavoritesPage(
          username: username,
        ),
      );
    },
  );
});

final blacklistedTagsHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  final args = context!.settings!.arguments as List;
  final int userId = args[0];

  return MultiBlocProvider(
    providers: [
      BlocProvider.value(
          value: BlocProvider.of<UserBlacklistedTagsBloc>(context)
            ..add(UserEventBlacklistedTagRequested(userId: userId))),
    ],
    child: BlacklistedTagsPage(
      userId: userId,
    ),
  );
});
