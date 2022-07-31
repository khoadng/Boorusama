// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
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
import 'package:boorusama/boorus/danbooru/presentation/features/characters/character_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/settings_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/app_rating.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/widgets/conditional_parent_widget.dart';
import 'presentation/features/accounts/profile/profile_page.dart';
import 'presentation/features/home/home_page.dart';
import 'presentation/features/post_detail/post_image_page.dart';
import 'presentation/features/search/search_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => ConditionalParentWidget(
    condition: canRate(),
    conditionalBuilder: (child) => createAppRatingWidget(child: child),
    child: const HomePage(),
  ),
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
      BlocProvider.value(
          value: context.read<ArtistCubit>()..getArtist(args[0])),
    ],
    child: ArtistPage(
      artistName: args[0],
      backgroundImageUrl: args[1],
    ),
  );
});

final characterHandler = Handler(handlerFunc: (
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
      BlocProvider.value(
          value: context.read<WikiBloc>()..add(WikiFetched(tag: args[0]))),
    ],
    child: CharacterPage(
      characterName: args[0],
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

  final screenSize = Screen.of(context).size;

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
      BlocProvider.value(
        value: context.read<RecommendedArtistPostCubit>()
          ..add(
            RecommendedPostRequested(
              amount: screenSize == ScreenSize.large ? 9 : 6,
              currentPostId: posts[index].id,
              tags: posts[index].artistTags,
            ),
          ),
      ),
      BlocProvider.value(
        value: context.read<RecommendedCharacterPostCubit>()
          ..add(
            RecommendedPostRequested(
              amount: screenSize == ScreenSize.large ? 9 : 6,
              currentPostId: posts[index].id,
              tags: posts[index].characterTags.take(3).toList(),
            ),
          ),
      ),
      BlocProvider.value(
        value: context.read<PoolFromPostIdBloc>()
          ..add(
            PoolFromPostIdRequested(postId: posts[index].id),
          ),
      ),
      BlocProvider.value(value: context.read<AuthenticationCubit>()),
      BlocProvider.value(value: context.read<ApiEndpointCubit>()),
      BlocProvider.value(value: context.read<ThemeBloc>()),
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
              initial: const SearchState(displayState: DisplayState.options))),
      BlocProvider(
          create: (context) => RelatedTagBloc(
              relatedTagRepository: context.read<RelatedTagRepository>())),
    ],
    child: SearchPage(
      metatags: context.read<TagInfo>().metatags,
      metatagHighlightColor: Theme.of(context).colorScheme.primary,
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
      BlocProvider.value(
          value: context.read<NoteBloc>()
            ..add(const NoteReset())
            ..add(NoteRequested(postId: args[0].id))),
    ],
    child: BlocSelector<SettingsCubit, SettingsState, ImageQuality>(
      selector: (state) => state.settings.imageQualityInFullView,
      builder: (context, quality) {
        return PostImagePage(
          post: args[0],
          useOriginalSize: quality == ImageQuality.original,
        );
      },
    ),
  );
});

final userHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  // final String userId = params["id"][0];

  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: context!.read<ProfileCubit>()..getProfile()),
      BlocProvider.value(value: context.read<FavoritesCubit>()),
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
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(
          value: BlocProvider.of<BlacklistedTagsBloc>(context!)
            ..add(const BlacklistedTagRequested())),
    ],
    child: const BlacklistedTagsPage(),
  );
});
