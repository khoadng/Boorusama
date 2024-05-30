// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/filename_generators/utils.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/video/videos_provider.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

enum PostDetailsPart {
  pool,
  info,
  toolbar,
  artistInfo,
  tags,
  stats,
  fileDetails,
  source,
  comments,
  artistPosts,
  relatedPosts,
  characterList,
}

const kDefaultPostDetailsParts = {
  PostDetailsPart.pool,
  PostDetailsPart.info,
  PostDetailsPart.toolbar,
  PostDetailsPart.artistInfo,
  PostDetailsPart.stats,
  PostDetailsPart.tags,
  PostDetailsPart.fileDetails,
  PostDetailsPart.source,
  PostDetailsPart.comments,
  PostDetailsPart.artistPosts,
  PostDetailsPart.relatedPosts,
  PostDetailsPart.characterList,
};

const kDefaultPostDetailsNoSourceParts = {
  PostDetailsPart.pool,
  PostDetailsPart.info,
  PostDetailsPart.toolbar,
  PostDetailsPart.artistInfo,
  PostDetailsPart.stats,
  PostDetailsPart.tags,
  PostDetailsPart.fileDetails,
  PostDetailsPart.comments,
  PostDetailsPart.artistPosts,
  PostDetailsPart.relatedPosts,
  PostDetailsPart.characterList,
};

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    this.toolbarBuilder,
    this.sliverArtistPostsBuilder,
    this.sliverCharacterPostsBuilder,
    this.onExpanded,
    this.tagListBuilder,
    this.infoBuilder,
    required this.swipeImageUrlBuilder,
    this.topRightButtonsBuilder,
    this.placeholderImageUrlBuilder,
    this.artistInfoBuilder,
    this.onPageChanged,
    this.onPageChangeIndexed,
    this.sliverRelatedPostsBuilder,
    this.commentsBuilder,
    this.poolTileBuilder,
    this.statsTileBuilder,
    this.fileDetailsBuilder,
    this.sourceSectionBuilder,
    this.parts = kDefaultPostDetailsParts,
  });

  final int initialIndex;
  final List<T> posts;
  final void Function(int page) onExit;
  final void Function(T post)? onExpanded;
  final void Function(T post)? onPageChanged;
  final void Function(int index)? onPageChangeIndexed;
  final String Function(T post) swipeImageUrlBuilder;
  final String? Function(T post, int currentPage)? placeholderImageUrlBuilder;
  final Widget Function(BuildContext context, T post)? toolbarBuilder;
  final List<Widget> Function(BuildContext context, T post)?
      sliverArtistPostsBuilder;
  final Widget Function(BuildContext context, T post)?
      sliverCharacterPostsBuilder;
  final Widget Function(BuildContext context, T post)? tagListBuilder;
  final Widget Function(BuildContext context, T post)? infoBuilder;
  final Widget Function(BuildContext context, T post)? artistInfoBuilder;
  final Widget Function(BuildContext context, T post)? commentsBuilder;
  final Widget Function(BuildContext context, T post)? poolTileBuilder;
  final Widget Function(BuildContext context, T post)? statsTileBuilder;
  final Widget Function(BuildContext context, T post)? fileDetailsBuilder;
  final Widget Function(BuildContext context, T post)? sourceSectionBuilder;

  final Set<PostDetailsPart> parts;

  final Widget Function(BuildContext context, T post)?
      sliverRelatedPostsBuilder;
  final List<Widget> Function(int currentPage, bool expanded, T post,
      DetailsPageController controller)? topRightButtonsBuilder;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>>
    with PostDetailsPageMixin<PostDetailsPageScaffold<T>, T> {
  late final _controller = DetailsPageController(
    swipeDownToDismiss: !widget.posts[widget.initialIndex].isVideo,
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
  );

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<T> get posts => widget.posts;

  @override
  int get initialPage => widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      backgroundColor: context.colorScheme.secondaryContainer,
      child: ValueListenableBuilder(
        valueListenable: controller.slideshow,
        builder: (context, slideshow, child) => GestureDetector(
          behavior: slideshow ? HitTestBehavior.opaque : null,
          onTap: () => controller.stopSlideshow(),
          child: IgnorePointer(
            ignoring: slideshow,
            child: child!,
          ),
        ),
        child: _build(),
      ),
    );
  }

  Widget _build() {
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;

    return LayoutBuilder(
      builder: (context, constraints) => DetailsPage(
        sharedChildBuilder: (page) => Column(
          children: [
            if (widget.infoBuilder != null)
              constraints.maxHeight > 450
                  ? widget.infoBuilder!(context, posts[page])
                  : const SizedBox.shrink(),
            widget.toolbarBuilder != null
                ? widget.toolbarBuilder!(context, posts[page])
                : SimplePostActionToolbar(post: posts[page]),
          ],
        ),
        currentSettings: () => ref.read(settingsProvider),
        controller: controller,
        intitialIndex: widget.initialIndex,
        onExit: widget.onExit,
        onPageChanged: (page) {
          onSwiped(page);
          widget.onPageChangeIndexed?.call(page);
          widget.onPageChanged?.call(posts[page]);
        },
        onSwipeDownEnd: booruBuilder?.canHandlePostGesture(
                      GestureType.swipeDown,
                      config.postGestures?.fullview,
                    ) ==
                    true &&
                postGesturesHandler != null
            ? (page) => postGesturesHandler(
                  ref,
                  config.postGestures?.fullview?.swipeDown,
                  posts[page],
                )
            : null,
        bottomSheet: (page, sharedChild) {
          final bottomSheet = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (posts[page].isVideo)
                ValueListenableBuilder(
                  valueListenable: videoProgress,
                  builder: (_, progress, __) => VideoSoundScope(
                    builder: (context, soundOn) => BooruVideoProgressBar(
                      soundOn: soundOn,
                      progress: progress,
                      playbackSpeed:
                          ref.watchPlaybackSpeed(posts[page].videoUrl),
                      onSeek: (position) => onVideoSeekTo(position, page),
                      onSpeedChanged: (speed) =>
                          ref.setPlaybackSpeed(posts[page].videoUrl, speed),
                      onSoundToggle: (value) => ref.setGlobalVideoSound(value),
                    ),
                  ),
                ),
              if (sharedChild != null)
                Container(
                  color: context.colorScheme.surface,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom,
                  ),
                  child: sharedChild,
                ),
            ],
          );

          return widget.infoBuilder != null
              ? Container(
                  decoration: BoxDecoration(
                    color:
                        context.theme.scaffoldBackgroundColor.withOpacity(0.8),
                    border: Border(
                      top: BorderSide(
                        color: context.theme.dividerColor,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: bottomSheet,
                )
              : bottomSheet;
        },
        targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
          imageUrl: posts[page].isVideo
              ? posts[page].videoThumbnailUrl
              : widget.swipeImageUrlBuilder(posts[page]),
          aspectRatio: posts[page].aspectRatio,
        ),
        expandedBuilder:
            (context, page, currentPage, expanded, enableSwipe, sharedChild) {
          final post = posts[page];
          final nextPost = posts.length > page + 1 ? posts[page + 1] : null;
          final expandedOnCurrentPage = expanded && page == currentPage;
          final media = PostMedia(
            inFocus: !expanded && page == currentPage,
            post: post,
            imageUrl: widget.swipeImageUrlBuilder(post),
            placeholderImageUrl: widget.placeholderImageUrlBuilder != null
                ? widget.placeholderImageUrlBuilder!(post, currentPage)
                : post.thumbnailImageUrl,
            onImageTap: onImageTap,
            onDoubleTap: booruBuilder?.canHandlePostGesture(
                          GestureType.doubleTap,
                          ref.watchConfig.postGestures?.fullview,
                        ) ==
                        true &&
                    postGesturesHandler != null
                ? () => postGesturesHandler(
                      ref,
                      ref.watchConfig.postGestures?.fullview?.doubleTap,
                      post,
                    )
                : null,
            onLongPress: booruBuilder?.canHandlePostGesture(
                          GestureType.longPress,
                          ref.watchConfig.postGestures?.fullview,
                        ) ==
                        true &&
                    postGesturesHandler != null
                ? () => postGesturesHandler(
                      ref,
                      ref.watchConfig.postGestures?.fullview?.longPress,
                      post,
                    )
                : null,
            onCurrentVideoPositionChanged: onCurrentPositionChanged,
            onVideoVisibilityChanged: onVisibilityChanged,
            imageOverlayBuilder: (constraints) => noteOverlayBuilderDelegate(
              constraints,
              post,
              ref.watch(notesControllerProvider(post)),
            ),
            useHero: page == currentPage,
            onImageZoomUpdated: onZoomUpdated,
            onVideoPlayerCreated: (controller) =>
                onVideoPlayerCreated(controller, page),
            onWebmVideoPlayerCreated: (controller) =>
                onWebmVideoPlayerCreated(controller, page),
            autoPlay: true,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomScrollView(
              physics:
                  enableSwipe ? null : const NeverScrollableScrollPhysics(),
              controller: PageContentScrollController.of(context),
              slivers: [
                // preload next image only, not the post itself
                if (nextPost != null && !nextPost.isVideo)
                  SliverOffstage(
                    offstage: true,
                    sliver: SliverToBoxAdapter(
                      child: ExtendedImage.network(
                        widget.swipeImageUrlBuilder(nextPost),
                        width: 1,
                        height: 1,
                        cacheHeight: 10,
                        cacheWidth: 10,
                        cache: true,
                      ),
                    ),
                  ),
                if (!expandedOnCurrentPage)
                  SliverSizedBox(
                    height: context.screenHeight -
                        MediaQuery.viewPaddingOf(context).top,
                    child: media,
                  )
                else
                  SliverToBoxAdapter(child: media),
                if (!expandedOnCurrentPage)
                  SliverSizedBox(height: context.screenHeight),
                if (expandedOnCurrentPage)
                  ...widget.parts
                      .map(
                        (p) => switch (p) {
                          PostDetailsPart.pool => widget.poolTileBuilder != null
                              ? SliverToBoxAdapter(
                                  child: widget.poolTileBuilder!(context, post),
                                )
                              : null,
                          PostDetailsPart.info => widget.infoBuilder != null
                              ? SliverToBoxAdapter(
                                  child: widget.infoBuilder!(context, post),
                                )
                              : null,
                          PostDetailsPart.toolbar => widget.toolbarBuilder !=
                                  null
                              ? SliverToBoxAdapter(
                                  child: widget.toolbarBuilder!(context, post),
                                )
                              : null,
                          PostDetailsPart.artistInfo => widget
                                      .artistInfoBuilder !=
                                  null
                              ? SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Divider(thickness: 0.5, height: 8),
                                      widget.artistInfoBuilder!(
                                        context,
                                        post,
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                          PostDetailsPart.stats =>
                            widget.statsTileBuilder != null
                                ? SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 8),
                                        widget.statsTileBuilder!(context, post),
                                        const Divider(thickness: 0.5),
                                      ],
                                    ),
                                  )
                                : null,
                          PostDetailsPart.tags => widget.tagListBuilder != null
                              ? SliverToBoxAdapter(
                                  child: widget.tagListBuilder!(context, post),
                                )
                              : SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: BasicTagList(
                                      tags: post.tags.toList(),
                                      onTap: (tag) =>
                                          goToSearchPage(context, tag: tag),
                                    ),
                                  ),
                                ),
                          PostDetailsPart.fileDetails => widget
                                      .fileDetailsBuilder !=
                                  null
                              ? SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      widget.fileDetailsBuilder!(context, post),
                                      const Divider(thickness: 0.5),
                                    ],
                                  ),
                                )
                              : SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      FileDetailsSection(
                                        post: post,
                                        rating: post.rating,
                                      ),
                                      const Divider(thickness: 0.5),
                                    ],
                                  ),
                                ),
                          PostDetailsPart.source =>
                            widget.sourceSectionBuilder != null
                                ? SliverToBoxAdapter(
                                    child: widget.sourceSectionBuilder!(
                                        context, post),
                                  )
                                : post.source.whenWeb(
                                    (source) => SliverToBoxAdapter(
                                      child: SourceSection(source: source),
                                    ),
                                    () => null,
                                  ),
                          PostDetailsPart.comments => widget.commentsBuilder !=
                                  null
                              ? SliverToBoxAdapter(
                                  child: widget.commentsBuilder!(context, post),
                                )
                              : null,
                          PostDetailsPart.artistPosts =>
                            widget.sliverArtistPostsBuilder != null
                                ? MultiSliver(
                                    children: widget.sliverArtistPostsBuilder!(
                                      context,
                                      post,
                                    ),
                                  )
                                : null,
                          PostDetailsPart.relatedPosts => widget
                                      .sliverRelatedPostsBuilder !=
                                  null
                              ? widget.sliverRelatedPostsBuilder!(context, post)
                              : null,
                          PostDetailsPart.characterList =>
                            widget.sliverCharacterPostsBuilder != null
                                ? widget.sliverCharacterPostsBuilder!(
                                    context, post)
                                : null,
                        },
                      )
                      .whereNotNull(),
                SliverSizedBox(
                  height: MediaQuery.paddingOf(context).bottom + 72,
                ),
              ],
            ),
          );
        },
        pageCount: widget.posts.length,
        topRightButtonsBuilder: (page, expanded) =>
            widget.topRightButtonsBuilder != null
                ? widget.topRightButtonsBuilder!(
                    page, expanded, posts[page], controller)
                : [
                    NoteActionButtonWithProvider(
                      post: posts[page],
                      expanded: expanded,
                      noteState:
                          ref.watch(notesControllerProvider(posts[page])),
                    ),
                    GeneralMoreActionButton(
                      post: widget.posts[page],
                      onStartSlideshow: () => controller.startSlideshow(),
                    ),
                  ],
        onExpanded: (currentPage) =>
            widget.onExpanded?.call(posts[currentPage]),
      ),
    );
  }
}
