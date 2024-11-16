// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/videos/videos.dart';
import 'package:boorusama/core/widgets/post_details_page_view.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

enum PostDetailsPart {
  pool,
  info,
  toolbar,
  artistInfo,
  source,
  tags,
  stats,
  fileDetails,
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
  PostDetailsPart.source,
  PostDetailsPart.tags,
  PostDetailsPart.fileDetails,
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
    this.postDetailsController,
    this.uiBuilder,
  });

  final int initialIndex;
  final List<T> posts;
  final void Function(int page) onExit;
  final void Function(T post)? onExpanded;
  final void Function(T post)? onPageChanged;
  final void Function(int index)? onPageChangeIndexed;
  final String Function(T post) swipeImageUrlBuilder;
  final String? Function(T post, int currentPage)? placeholderImageUrlBuilder;
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

  final PostDetailsController<T>? postDetailsController;

  final PostDetailsUIBuilder? uiBuilder;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>>
    with PostDetailsPageMixin<PostDetailsPageScaffold<T>, T> {
  late final _posts = widget.posts;
  late final _controller = DetailsPageController(
    initialPage: widget.initialIndex,
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
  );

  @override
  DetailsPageController get controller => _controller;

  PostDetailsPageViewController get _pageController =>
      controller.pageViewController;

  @override
  List<T> get posts => _posts;

  @override
  int get initialPage => widget.initialIndex;

  @override
  void initState() {
    super.initState();
    controller.pageViewController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = controller.pageViewController.currentPage;

    onSwiped(page);
    ref
        .read(postShareProvider(posts[page]).notifier)
        .updateInformation(posts[page]);
    widget.onPageChangeIndexed?.call(page);
    widget.onPageChanged?.call(posts[page]);
  }

  @override
  void dispose() {
    controller.pageViewController.currentPageNotifier
        .removeListener(_onPageChanged);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsProvider.select((value) => value.hidePostDetailsOverlay),
      (previous, next) {
        if (previous != next && _controller.hideOverlay.value != next) {
          _controller.setHideOverlay(next);
        }
      },
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            controller.nextPage(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            controller.previousPage(),
        const SingleActivator(LogicalKeyboardKey.keyO): () =>
            controller.toggleOverlay(),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop();
          widget.onExit(controller.currentPage.value);
        },
      },
      child: Focus(
        autofocus: true,
        child: CustomContextMenuOverlay(
          backgroundColor: context.colorScheme.secondaryContainer,
          child: ValueListenableBuilder(
            valueListenable: controller.slideshow,
            builder: (context, slideshow, child) => GestureDetector(
              behavior: slideshow ? HitTestBehavior.opaque : null,
              onTap: () => controller.stopSlideshow(),
              child: IgnorePointer(
                ignoring: slideshow,
                child: child,
              ),
            ),
            child: ValueListenableBuilder(
              valueListenable: controller.currentPage,
              builder: (_, page, __) => _build(page),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build(int currentPage) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final toolbarBuilder = widget.uiBuilder?.toolbarBuilder ??
        booruBuilder?.postDetailsUIBuilder.toolbarBuilder;
    final focusedPost = posts[currentPage];

    return DetailsPage(
      currentSettings: () => ref.read(settingsProvider),
      controller: controller,
      intitialIndex: widget.initialIndex,
      onExit: widget.onExit,
      itemCount: posts.length,
      onSwipeDownThresholdReached: booruBuilder?.canHandlePostGesture(
                    GestureType.swipeDown,
                    config.postGestures?.fullview,
                  ) ==
                  true &&
              postGesturesHandler != null
          ? () {
              _controller.pageViewController.resetSheet();

              postGesturesHandler(
                ref,
                config.postGestures?.fullview?.swipeDown,
                focusedPost,
              );
            }
          : null,
      info: ValueListenableBuilder(
        valueListenable: _pageController.currentPageNotifier,
        builder: (context, index, child) {
          return ValueListenableBuilder(
            valueListenable: _pageController.expandedNotifier,
            builder: (context, expanded, _) {
              return _buildSheet(
                PostDetailsSheetScrollController.of(context),
                context,
                posts[index],
                expanded,
              );
            },
          );
        },
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        final page = index;

        final media = PostMedia(
          inFocus: true,
          post: post,
          imageUrl: widget.swipeImageUrlBuilder(post),
          placeholderImageUrl: widget.placeholderImageUrlBuilder != null
              ? widget.placeholderImageUrlBuilder!(post, currentPage)
              : post.thumbnailImageUrl,
          onCurrentVideoPositionChanged: onCurrentPositionChanged,
          onVideoVisibilityChanged: onVisibilityChanged,
          imageOverlayBuilder: (constraints) => noteOverlayBuilderDelegate(
            constraints,
            post,
            ref.watch(notesControllerProvider(post)),
          ),
          useHero: page == currentPage,
          onVideoPlayerCreated: (controller) =>
              onVideoPlayerCreated(controller, page),
          onWebmVideoPlayerCreated: (controller) =>
              onWebmVideoPlayerCreated(controller, page),
          autoPlay: true,
        );

        final (previousPost, nextPost) = posts.getPrevAndNextPosts(page);

        return Column(
          children: [
            // preload next image only, not the post itself
            if (nextPost != null && !nextPost.isVideo)
              Offstage(
                child: PostDetailsPreloadImage(
                  url: widget.swipeImageUrlBuilder(nextPost),
                ),
              ),
            if (previousPost != null && !previousPost.isVideo)
              Offstage(
                child: PostDetailsPreloadImage(
                  url: widget.swipeImageUrlBuilder(previousPost),
                ),
              ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _pageController.currentPageNotifier,
                builder: (_, currentPage, child) => page == currentPage
                    ? ValueListenableBuilder(
                        valueListenable: _pageController.topDisplacement,
                        builder: (_, dis, __) {
                          // final scale = (1.0 - (dis / 500)).clamp(0.8, 1.0);

                          return Transform.scale(
                            scale: 1,
                            child: child,
                          );
                        },
                      )
                    : child!,
                child: InteractiveViewExtended(
                  onZoomUpdated: onZoomUpdated,
                  onTap: onImageTap,
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
                  child: media,
                ),
              ),
            ),
          ],
        );
      },
      bottomSheet: ConditionalParentWidget(
        condition: widget.infoBuilder != null,
        conditionalBuilder: (child) => DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surface.applyOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: context.theme.dividerColor,
                width: 0.2,
              ),
            ),
          ),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (focusedPost.isVideo)
              ValueListenableBuilder(
                valueListenable: videoProgress,
                builder: (_, progress, __) => VideoSoundScope(
                  builder: (context, soundOn) => BooruVideoProgressBar(
                    soundOn: soundOn,
                    progress: progress,
                    playbackSpeed: ref.watchPlaybackSpeed(focusedPost.videoUrl),
                    onSeek: (position) => onVideoSeekTo(position, currentPage),
                    onSpeedChanged: (speed) =>
                        ref.setPlaybackSpeed(focusedPost.videoUrl, speed),
                    onSoundToggle: (value) => ref.setGlobalVideoSound(value),
                  ),
                ),
              ),
            Container(
              color: context.colorScheme.surface,
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  if (widget.infoBuilder != null)
                    widget.infoBuilder!(context, focusedPost),
                  toolbarBuilder != null
                      ? toolbarBuilder(context)
                      : DefaultPostActionToolbar(post: focusedPost),
                ],
              ),
            ),
          ],
        ),
      ),
      topRightButtons: ValueListenableBuilder(
        valueListenable: _pageController.expandedNotifier,
        builder: (_, expanded, __) => Padding(
          padding: const EdgeInsets.all(8),
          child: OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 4,
            children: [
              ...widget.topRightButtonsBuilder != null
                  ? widget.topRightButtonsBuilder!(
                      currentPage,
                      expanded,
                      focusedPost,
                      controller,
                    )
                  : [
                      NoteActionButtonWithProvider(
                        post: focusedPost,
                        expanded: expanded,
                        noteState:
                            ref.watch(notesControllerProvider(focusedPost)),
                      ),
                      GeneralMoreActionButton(
                        post: focusedPost,
                        onStartSlideshow: () => controller.startSlideshow(),
                      ),
                    ],
            ],
          ),
        ),
      ),
      onExpanded: () => widget.onExpanded?.call(focusedPost),
    );
  }

  Widget _buildSheet(
    ScrollController scrollController,
    BuildContext context,
    T post,
    bool expanded,
  ) {
    final booruBuilder = ref.watchBooruBuilder(ref.watchConfig);
    final toolbarBuilder = widget.uiBuilder?.toolbarBuilder ??
        booruBuilder?.postDetailsUIBuilder.toolbarBuilder;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          const SliverSizedBox(height: 12),
          if (expanded)
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
                    PostDetailsPart.toolbar => toolbarBuilder != null
                        ? SliverToBoxAdapter(
                            child: toolbarBuilder(context),
                          )
                        : SliverToBoxAdapter(
                            child: DefaultInheritedPostActionToolbar<T>(),
                          ),
                    PostDetailsPart.artistInfo =>
                      widget.artistInfoBuilder != null
                          ? SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    PostDetailsPart.stats => widget.statsTileBuilder != null
                        ? SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                vertical: 12,
                              ),
                              child: BasicTagList(
                                tags: post.tags.toList(),
                                onTap: (tag) =>
                                    goToSearchPage(context, tag: tag),
                              ),
                            ),
                          ),
                    PostDetailsPart.fileDetails =>
                      widget.fileDetailsBuilder != null
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
                    PostDetailsPart.source => widget.sourceSectionBuilder !=
                            null
                        ? SliverToBoxAdapter(
                            child: widget.sourceSectionBuilder!(context, post),
                          )
                        : post.source.whenWeb(
                            (source) => SliverToBoxAdapter(
                              child: SourceSection(source: source),
                            ),
                            () => null,
                          ),
                    PostDetailsPart.comments => widget.commentsBuilder != null
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
                    PostDetailsPart.relatedPosts =>
                      widget.sliverRelatedPostsBuilder != null
                          ? widget.sliverRelatedPostsBuilder!(context, post)
                          : null,
                    PostDetailsPart.characterList =>
                      widget.sliverCharacterPostsBuilder != null
                          ? widget.sliverCharacterPostsBuilder!(context, post)
                          : null,
                  },
                )
                .nonNulls,
          SliverSizedBox(
            height: MediaQuery.paddingOf(context).bottom + 72,
          ),
        ],
      ),
    );
  }
}
