// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../configs/create/widgets.dart';
import '../../../configs/ref.dart';
import '../../../home/custom_home.dart';
import '../../../home/home_page_scaffold.dart';
import '../../../home/mobile_home_page_scaffold.dart';
import '../../../home/user_custom_home_builder.dart';
import '../../../notes/notes.dart';
import '../../../posts/details/details.dart';
import '../../../posts/details/providers.dart';
import '../../../posts/details/widgets.dart';
import '../../../posts/details_manager/types.dart';
import '../../../posts/details_parts/widgets.dart';
import '../../../posts/favorites/widgets.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/post.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/statistics/stats.dart';
import '../../../posts/statistics/widgets.dart';
import '../../../router.dart';
import '../../../search/search/widgets.dart';
import '../../../search/suggestions/widgets.dart';
import '../../../tags/categories/tag_category.dart';
import '../../../tags/show/widgets.dart';
import '../../../tags/tag/tag.dart';
import '../../../tags/tag/widgets.dart';
import '../../../theme.dart';
import '../providers.dart';
import 'booru_builder.dart';
import 'booru_builder_types.dart';

mixin FavoriteNotSupportedMixin implements BooruBuilder {
  @override
  FavoritesPageBuilder? get favoritesPageBuilder => null;
  @override
  QuickFavoriteButtonBuilder? get quickFavoriteButtonBuilder => null;
}

mixin DefaultQuickFavoriteButtonBuilderMixin implements BooruBuilder {
  @override
  QuickFavoriteButtonBuilder get quickFavoriteButtonBuilder =>
      (context, post) => DefaultQuickFavoriteButton(
        post: post,
      );
}

mixin ArtistNotSupportedMixin implements BooruBuilder {
  @override
  ArtistPageBuilder? get artistPageBuilder => null;
}

mixin CharacterNotSupportedMixin implements BooruBuilder {
  @override
  CharacterPageBuilder? get characterPageBuilder => null;
}

mixin CommentNotSupportedMixin implements BooruBuilder {
  @override
  CommentPageBuilder? get commentPageBuilder => null;
}

mixin DefaultTagSuggestionsItemBuilderMixin implements BooruBuilder {
  @override
  TagSuggestionItemBuilder get tagSuggestionItemBuilder =>
      (
        config,
        tag,
        dense,
        currentQuery,
        onItemTap,
      ) => DefaultTagSuggestionItem(
        config: config,
        tag: tag,
        onItemTap: onItemTap,
        currentQuery: currentQuery,
        dense: dense,
      );
}

mixin DefaultPostStatisticsPageBuilderMixin on BooruBuilder {
  @override
  PostStatisticsPageBuilder get postStatisticsPageBuilder =>
      (context, posts) => PostStatisticsPage(
        generalStats: () => posts.getStats(),
        totalPosts: () => posts.length,
      );
}

mixin DefaultUnknownBooruWidgetsBuilderMixin implements BooruBuilder {
  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const DefaultUnknownBooruWidgets();
}

mixin DefaultMultiSelectionActionsBuilderMixin on BooruBuilder {
  @override
  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder =>
      (context, controller, postController) => DefaultMultiSelectionActions(
        postController: postController,
      );
}

mixin DefaultBooruUIMixin implements BooruBuilder {
  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const HomePageScaffold();

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => DefaultSearchPage(
        params: params,
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: payload.posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage(),
    );
  };
}

class DefaultPostDetailsPage<T extends Post> extends ConsumerStatefulWidget {
  const DefaultPostDetailsPage({
    super.key,
  });

  @override
  ConsumerState<DefaultPostDetailsPage<T>> createState() =>
      _DefaultPostDetailsPageState<T>();
}

class _DefaultPostDetailsPageState<T extends Post>
    extends ConsumerState<DefaultPostDetailsPage<T>> {
  final _transformController = TransformationController();
  final _isInitPage = ValueNotifier(true);

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<T>(context);
    final posts = data.posts;
    final controller = data.controller;
    final auth = ref.watchConfigAuth;
    final viewer = ref.watchConfigViewer;
    final layout = ref.watchLayoutConfigs;
    final gestures = ref.watchPostGestures;
    final booruBuilder = ref.watch(booruBuilderProvider(auth));
    final booruRepo = ref.watch(booruRepoProvider(auth));
    final uiBuilder = booruBuilder?.postDetailsUIBuilder;
    final mediaUrlResolver = ref.watch(mediaUrlResolverProvider(auth));

    return PostDetailsImagePreloader(
      authConfig: auth,
      posts: posts,
      imageUrlBuilder: (post) => mediaUrlResolver.resolveMediaUrl(post, viewer),
      child: PostDetailsNotes(
        posts: posts,
        viewerConfig: viewer,
        authConfig: auth,
        child: PostDetailsPageScaffold(
          transformController: _transformController,
          isInitPage: _isInitPage,
          controller: controller,
          posts: posts,
          postGestureHandlerBuilder: booruRepo?.handlePostGesture,
          uiBuilder: uiBuilder,
          gestureConfig: gestures,
          layoutConfig: layout,
          actions: defaultActions(
            note: NoteActionButtonWithProvider(
              currentPost: controller.currentPost,
              config: auth,
            ),
            fallbackMoreButton: DefaultFallbackBackupMoreButton(
              layoutConfig: layout,
              controller: controller,
              authConfig: auth,
              viewerConfig: viewer,
            ),
          ),
          itemBuilder: (context, index) {
            return PostDetailsItem(
              index: index,
              posts: posts,
              transformController: _transformController,
              isInitPageListenable: _isInitPage,
              authConfig: auth,
              gestureConfig: gestures,
              imageCacheManager: null,
              detailsController: controller,
              imageUrlBuilder: (post) =>
                  mediaUrlResolver.resolveMediaUrl(post, viewer),
            );
          },
        ),
      ),
    );
  }
}

class DefaultSearchPage extends ConsumerWidget {
  const DefaultSearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controler) => postRepo.getPostsFromController(
        controler.tagSet,
        page,
      ),
    );
  }
}

mixin DefaultHomeMixin implements BooruBuilder {
  @override
  HomeViewBuilder get homeViewBuilder =>
      (context) => const UserCustomHomeBuilder(
        defaultView: MobileHomePageScaffold(),
      );

  @override
  final Map<CustomHomeViewKey, CustomHomeDataBuilder> customHomeViewBuilders =
      kDefaultAltHomeView;
}

mixin DefaultViewTagListBuilderMixin implements BooruBuilder {
  @override
  ViewTagListBuilder get viewTagListBuilder =>
      (context, post, initiallyMultiSelectEnabled, auth) =>
          _DefaultShowTagListPage(
            post: post,
            initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
            auth: auth,
          );
}

class _DefaultShowTagListPage extends StatelessWidget {
  const _DefaultShowTagListPage({
    required this.post,
    required this.initiallyMultiSelectEnabled,
    required this.auth,
  });

  final Post post;
  final BooruConfigAuth auth;
  final bool initiallyMultiSelectEnabled;

  @override
  Widget build(BuildContext context) {
    return ShowTagListPage(
      post: post,
      initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
      auth: auth,
    );
  }
}

class DefaultImagePreviewQuickActionButton extends ConsumerWidget {
  const DefaultImagePreviewQuickActionButton({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watch(booruBuilderProvider(config.auth));

    return switch (config.defaultPreviewImageButtonActionType) {
      ImageQuickActionType.bookmark => Container(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 1,
          right: 1,
          left: 3,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.extendedColorScheme.surfaceContainerOverlay,
        ),
        child: BookmarkPostLikeButtonButton(
          post: post,
        ),
      ),
      ImageQuickActionType.download => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.extendedColorScheme.surfaceContainerOverlay,
        ),
        child: DownloadPostButton(
          post: post,
          small: true,
        ),
      ),
      ImageQuickActionType.artist => Builder(
        builder: (context) {
          final artist = post.artistTags != null && post.artistTags!.isNotEmpty
              ? chooseArtistTag(post.artistTags!)
              : null;
          if (artist == null) return const SizedBox.shrink();

          return PostTagListChip(
            tag: Tag.noCount(
              name: artist,
              category: TagCategory.artist(),
            ),
            auth: config.auth,
            onTap: () => goToArtistPage(
              ref,
              artist,
            ),
          );
        },
      ),
      ImageQuickActionType.defaultAction =>
        booruBuilder?.quickFavoriteButtonBuilder != null
            ? booruBuilder!.quickFavoriteButtonBuilder!(
                context,
                post,
              )
            : const SizedBox.shrink(),
      ImageQuickActionType.none => const SizedBox.shrink(),
    };
  }
}

final kFallbackPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) => const DefaultInheritedPostActionToolbar(),
  },
  full: {
    DetailsPart.toolbar: (context) => const DefaultInheritedPostActionToolbar(),
    DetailsPart.tags: (context) => const DefaultInheritedBasicTagsTile(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection(),
  },
);
