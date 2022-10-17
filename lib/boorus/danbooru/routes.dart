// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
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
import 'package:boorusama/boorus/danbooru/application/post/post_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/ui/features/accounts/login/login_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/artists/artist_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/characters/character_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/settings_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/app_rating.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'ui/features/accounts/profile/profile_page.dart';
import 'ui/features/home/home_page.dart';
import 'ui/features/post_detail/post_image_page.dart';
import 'ui/features/search/search_page.dart';

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
          create: (context) => PostBloc.of(context)
            ..add(PostRefreshed(
              tag: args[0],
              fetcher: SearchedPostFetcher.fromTags(args[0]),
            ))),
      BlocProvider.value(
          value: context.read<ArtistBloc>()..add(ArtistFetched(name: args[0]))),
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
          create: (context) => PostBloc.of(context)
            ..add(PostRefreshed(
              tag: args[0],
              fetcher: SearchedPostFetcher.fromTags(args[0]),
            ))),
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
  final postDatas = args[0] as List<PostData>;
  final index = args[1] as int;

  final AutoScrollController? controller = args[2];
  final PostBloc? postBloc = args[3];

  final tags = postDatas
      .map((e) => e.post)
      .map((p) => [
            ...p.artistTags.map((e) => PostDetailTag(
                  name: e,
                  category: TagAutocompleteCategory.artist(),
                  postId: p.id,
                )),
            ...p.characterTags.map((e) => PostDetailTag(
                  name: e,
                  category: TagAutocompleteCategory.character(),
                  postId: p.id,
                )),
            ...p.copyrightTags.map((e) => PostDetailTag(
                  name: e,
                  category: TagAutocompleteCategory.copyright(),
                  postId: p.id,
                )),
            ...p.generalTags.map((e) => PostDetailTag(
                  name: e,
                  category: TagAutocompleteCategory.general(),
                  postId: p.id,
                )),
            ...p.metaTags.map((e) => PostDetailTag(
                  name: e,
                  category: TagAutocompleteCategory.meta(),
                  postId: p.id,
                )),
          ])
      .expand((e) => e)
      .toList();

  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => SliverPostGridBloc()),
      BlocProvider.value(value: context.read<AuthenticationCubit>()),
      BlocProvider.value(value: context.read<ApiEndpointCubit>()),
      BlocProvider.value(value: context.read<ThemeBloc>()),
      BlocProvider(
        create: (context) => PostDetailBloc(
          postRepository: context.read<PostRepository>(),
          tags: tags,
          onPostUpdated: (postId, tag, category) {
            if (postBloc == null) return;

            final posts = postDatas.where((e) => e.post.id == postId).toList();
            if (posts.isEmpty) return;

            postBloc.add(PostUpdated(
                post: _newPost(
              posts.first.post,
              tag,
              category,
            )));
          },
        ),
      )
    ],
    child: RepositoryProvider.value(
      value: context.read<TagRepository>(),
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
            intitialIndex: index,
            posts: postDatas,
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
                  context.read<SearchHistoryRepository>())),
      BlocProvider(create: (context) => PostBloc.of(context)),
      BlocProvider.value(value: BlocProvider.of<ThemeBloc>(context)),
      BlocProvider(
          create: (context) => TagSearchBloc(
                tagInfo: context.read<TagInfo>(),
                autocompleteRepository: context.read<AutocompleteRepository>(),
              )),
      BlocProvider(
          create: (context) => SearchHistorySuggestionsBloc(
              searchHistoryRepository:
                  context.read<SearchHistoryRepository>())),
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
          BlocProvider.value(
              value: PoolDescriptionBloc(
            endpoint: state.booru.url,
            poolDescriptionRepository:
                context.read<PoolDescriptionRepository>(),
          )..add(PoolDescriptionFetched(poolId: pool.id))),
          BlocProvider(
              create: (context) => NoteBloc(
                  noteRepository:
                      RepositoryProvider.of<NoteRepository>(context))),
        ],
        child: PoolDetailPage(
          pool: pool,
          postIds: QueueList.from(pool.postIds),
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
              create: (context) => PostBloc.of(context)
                ..add(PostRefreshed(
                    tag: 'ordfav:$username',
                    fetcher: SearchedPostFetcher.fromTags(
                      'ordfav:$username',
                    )))),
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

Post _newPost(Post post, String tag, TagCategory category) {
  if (category == TagCategory.artist) {
    return post.copyWith(
      artistTags: [...post.artistTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else if (category == TagCategory.copyright) {
    return post.copyWith(
      copyrightTags: [...post.copyrightTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else if (category == TagCategory.charater) {
    return post.copyWith(
      characterTags: [...post.characterTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else if (category == TagCategory.meta) {
    return post.copyWith(
      metaTags: [...post.metaTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  } else {
    return post.copyWith(
      generalTags: [...post.generalTags, tag]..sort(),
      tags: [...post.tags, tag]..sort(),
    );
  }
}
