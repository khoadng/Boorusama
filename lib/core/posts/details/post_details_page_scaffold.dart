// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/videos/videos.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

const kDefaultPostDetailsParts = {
  DetailsPart.pool,
  DetailsPart.info,
  DetailsPart.toolbar,
  DetailsPart.artistInfo,
  DetailsPart.stats,
  DetailsPart.source,
  DetailsPart.tags,
  DetailsPart.fileDetails,
  DetailsPart.comments,
  DetailsPart.artistPosts,
  DetailsPart.relatedPosts,
  DetailsPart.characterList,
};

const kDefaultPostDetailsNoSourceParts = {
  DetailsPart.pool,
  DetailsPart.info,
  DetailsPart.toolbar,
  DetailsPart.artistInfo,
  DetailsPart.stats,
  DetailsPart.tags,
  DetailsPart.fileDetails,
  DetailsPart.comments,
  DetailsPart.artistPosts,
  DetailsPart.relatedPosts,
  DetailsPart.characterList,
};

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    super.key,
    required this.posts,
    this.sliverArtistPostsBuilder,
    this.sliverCharacterPostsBuilder,
    this.onExpanded,
    this.tagListBuilder,
    this.infoBuilder,
    this.imageUrlBuilder,
    this.topRightButtonsBuilder,
    this.placeholderImageUrlBuilder,
    this.artistInfoBuilder,
    this.sliverRelatedPostsBuilder,
    this.commentsBuilder,
    this.poolTileBuilder,
    this.statsTileBuilder,
    this.fileDetailsBuilder,
    this.sourceSectionBuilder,
    this.parts = kDefaultPostDetailsParts,
    required this.controller,
    this.uiBuilder,
  });

  final List<T> posts;
  final void Function(T post)? onExpanded;
  final String Function(T post)? imageUrlBuilder;
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

  final Set<DetailsPart> parts;

  final Widget Function(BuildContext context, T post)?
      sliverRelatedPostsBuilder;
  final List<Widget> Function(int currentPage, bool expanded, T post,
      DetailsPageMobileController controller)? topRightButtonsBuilder;

  final PostDetailsController<T> controller;

  final PostDetailsUIBuilder? uiBuilder;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>>
    with PostDetailsPageMixin<PostDetailsPageScaffold<T>, T> {
  late final _posts = widget.posts;
  late final _controller = DetailsPageMobileController(
    initialPage: widget.controller.initialPage,
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
    totalPageFetcher: () => _posts.length,
    pageSyncronizer: widget.controller.setPage,
  );

  @override
  DetailsPageMobileController get controller => _controller;

  @override
  List<T> get posts => _posts;

  @override
  void initState() {
    super.initState();
    controller.currentLocalPage.addListener(_onPageChanged);
    controller.init();
  }

  void _onPageChanged() {
    final page = controller.currentLocalPage.value;

    onPageChanged();
    ref
        .read(postShareProvider(posts[page]).notifier)
        .updateInformation(posts[page]);
  }

  void _onExit() {
    widget.controller.onExit();
  }

  @override
  void dispose() {
    controller.currentLocalPage.removeListener(_onPageChanged);
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
          _onExit();
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
              valueListenable: controller.currentLocalPage,
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

    final imageUrlBuilder =
        widget.imageUrlBuilder ?? defaultPostImageUrlBuilder(ref);

    final focusedPost = posts[currentPage];

    final postDetailsUIBuilder = booruBuilder?.postDetailsUIBuilder;

    return DetailsPageMobile(
      currentSettings: () => ref.read(settingsProvider),
      controller: controller,
      onExit: _onExit,
      itemCount: posts.length,
      onSwipeDownThresholdReached: booruBuilder?.canHandlePostGesture(
                    GestureType.swipeDown,
                    config.postGestures?.fullview,
                  ) ==
                  true &&
              postGesturesHandler != null
          ? () {
              _controller.resetSheet();

              postGesturesHandler(
                ref,
                config.postGestures?.fullview?.swipeDown,
                focusedPost,
              );
            }
          : null,
      info: Builder(
        builder: (context) => ValueListenableBuilder(
          valueListenable: controller.expanded,
          builder: (context, expanded, _) => PostDetailsFullInfoSheet(
            scrollController: PostDetailsSheetScrollController.of(context),
            expanded: expanded,
          ),
        ),
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        final page = index;

        final media = PostMedia(
          inFocus: true,
          post: post,
          imageUrl: imageUrlBuilder(post),
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
                  url: imageUrlBuilder(nextPost),
                ),
              ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _controller.topDisplacement,
                builder: (_, dis, child) {
                  final scale = (1.0 - (dis / 500)).clamp(0.85, 1.0);

                  return Transform.scale(
                    scale: scale,
                    child: child!,
                  );
                },
                child: ValueListenableBuilder(
                  valueListenable: _controller.expanded,
                  builder: (_, expanded, __) => InteractiveViewExtended(
                    enable: !expanded,
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
            ),
            if (previousPost != null && !previousPost.isVideo)
              Offstage(
                child: PostDetailsPreloadImage(
                  url: imageUrlBuilder(previousPost),
                ),
              ),
          ],
        );
      },
      bottomSheet: widget.uiBuilder != null
          ? _buildCustomPreview(widget.uiBuilder!, focusedPost)
          : postDetailsUIBuilder != null &&
                  postDetailsUIBuilder.preview.isNotEmpty
              ? _buildCustomPreview(
                  postDetailsUIBuilder,
                  focusedPost,
                )
              : _buildFallbackPreview(focusedPost: focusedPost),
      topRightButtons: ValueListenableBuilder(
        valueListenable: _controller.expanded,
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

  Widget _buildCustomPreview(PostDetailsUIBuilder uiBuilder, T focusedPost) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (focusedPost.isVideo) _buildVideoControls(focusedPost),
        ColoredBox(
          color: context.colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final part in uiBuilder.preview.keys)
                uiBuilder.buildPart(context, part),
              SizedBox(
                height: MediaQuery.paddingOf(context).bottom,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackPreview({
    required T focusedPost,
  }) {
    final booruBuilder = ref.watchBooruBuilder(ref.watchConfig);
    final legacyToolbarBuilder = widget.uiBuilder?.toolbarBuilder ??
        booruBuilder?.postDetailsUIBuilder.toolbarBuilder;

    final toolbarBuilder = widget.uiBuilder?.preview.isNotEmpty == true
        ? widget.uiBuilder?.preview[DetailsPart.toolbar] ?? legacyToolbarBuilder
        : legacyToolbarBuilder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (focusedPost.isVideo) _buildVideoControls(focusedPost),
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
    );
  }

  Widget _buildVideoControls(focusedPost) {
    return ValueListenableBuilder(
      valueListenable: videoProgress,
      builder: (_, progress, __) => VideoSoundScope(
        builder: (context, soundOn) => BooruVideoProgressBar(
          soundOn: soundOn,
          progress: progress,
          playbackSpeed: ref.watchPlaybackSpeed(focusedPost.videoUrl),
          onSeek: (position) =>
              onVideoSeekTo(position, controller.currentLocalPage.value),
          onSpeedChanged: (speed) =>
              ref.setPlaybackSpeed(focusedPost.videoUrl, speed),
          onSoundToggle: (value) => ref.setGlobalVideoSound(value),
        ),
      ),
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
                    DetailsPart.pool => widget.poolTileBuilder != null
                        ? SliverToBoxAdapter(
                            child: widget.poolTileBuilder!(context, post),
                          )
                        : null,
                    DetailsPart.info => widget.infoBuilder != null
                        ? SliverToBoxAdapter(
                            child: widget.infoBuilder!(context, post),
                          )
                        : null,
                    DetailsPart.toolbar => toolbarBuilder != null
                        ? SliverToBoxAdapter(
                            child: toolbarBuilder(context),
                          )
                        : SliverToBoxAdapter(
                            child: DefaultInheritedPostActionToolbar<T>(),
                          ),
                    DetailsPart.artistInfo => widget.artistInfoBuilder != null
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
                    DetailsPart.stats => widget.statsTileBuilder != null
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
                    DetailsPart.tags => widget.tagListBuilder != null
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
                    DetailsPart.fileDetails => widget.fileDetailsBuilder != null
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
                    DetailsPart.source => widget.sourceSectionBuilder != null
                        ? SliverToBoxAdapter(
                            child: widget.sourceSectionBuilder!(context, post),
                          )
                        : post.source.whenWeb(
                            (source) => SliverToBoxAdapter(
                              child: SourceSection(source: source),
                            ),
                            () => null,
                          ),
                    DetailsPart.comments => widget.commentsBuilder != null
                        ? SliverToBoxAdapter(
                            child: widget.commentsBuilder!(context, post),
                          )
                        : null,
                    DetailsPart.artistPosts =>
                      widget.sliverArtistPostsBuilder != null
                          ? MultiSliver(
                              children: widget.sliverArtistPostsBuilder!(
                                context,
                                post,
                              ),
                            )
                          : null,
                    DetailsPart.relatedPosts =>
                      widget.sliverRelatedPostsBuilder != null
                          ? widget.sliverRelatedPostsBuilder!(context, post)
                          : null,
                    DetailsPart.characterList =>
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

class PostDetailsFullInfoSheet extends ConsumerWidget {
  const PostDetailsFullInfoSheet({
    super.key,
    this.scrollController,
    required this.expanded,
  });

  final ScrollController? scrollController;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watchBooruBuilder(ref.watchConfig);
    final uiBuilder = booruBuilder?.postDetailsUIBuilder;

    if (uiBuilder == null) {
      return const DefaultPostDetailsInfoPreview();
    }

    return RawPostDetailsInfoSheet(
      scrollController: scrollController,
      preview: const DefaultPostDetailsInfoPreview(),
      sliver: MultiSliver(
        children: [
          ...uiBuilder.full.keys.map((p) => uiBuilder.buildPart(context, p)),
        ],
      ),
      expanded: expanded,
    );
  }
}

class RawPostDetailsInfoSheet extends StatelessWidget {
  const RawPostDetailsInfoSheet({
    super.key,
    required this.scrollController,
    required this.preview,
    required this.sliver,
    required this.expanded,
  });

  final ScrollController? scrollController;
  final Widget preview;
  final Widget sliver;

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return preview;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          const SliverSizedBox(height: 12),
          sliver,
          SliverSizedBox(
            height: MediaQuery.paddingOf(context).bottom + 72,
          ),
        ],
      ),
    );
  }
}

class DefaultPostDetailsInfoPreview extends StatelessWidget {
  const DefaultPostDetailsInfoPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        controller: PostDetailsSheetScrollController.of(context),
        slivers: [
          const SliverSizedBox(height: 12),
          SliverSizedBox(
            height: MediaQuery.paddingOf(context).bottom + 72,
          ),
        ],
      ),
    );
  }
}

mixin PostDetailsPageMixin<T extends StatefulWidget, E extends Post>
    on State<T> {
  final _videoProgress = ValueNotifier(VideoProgress.zero);

  //TODO: should have an abstraction for this crap, but I'm too lazy to do it since there are only 2 types of video anyway
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, WebmVideoController> _webmVideoControllers = {};

  List<E> get posts;
  DetailsPageMobileController get controller;
  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;

  void onPageChanged() {
    _videoProgress.value = VideoProgress.zero;

    final page = controller.currentLocalPage.value;

    // Pause previous video
    if (posts[page].videoUrl.endsWith('.webm')) {
      _webmVideoControllers[page]?.pause();
    } else {
      _videoControllers[page]?.pause();
    }
  }

  void onCurrentPositionChanged(double current, double total, String url) {
    final page = controller.currentLocalPage.value;
    // check if the current video is the same as the one being played
    if (posts[page].videoUrl != url) return;

    _videoProgress.value = VideoProgress(
        Duration(milliseconds: (total * 1000).toInt()),
        Duration(milliseconds: (current * 1000).toInt()));
  }

  void onVideoSeekTo(Duration position, int page) {
    if (posts[page].videoUrl.endsWith('.webm')) {
      _webmVideoControllers[page]?.seek(position.inSeconds.toDouble());
    } else {
      _videoControllers[page]?.seekTo(position);
    }
  }

  void onWebmVideoPlayerCreated(WebmVideoController controller, int page) {
    _webmVideoControllers[page] = controller;
  }

  void onVideoPlayerCreated(VideoPlayerController controller, int page) {
    _videoControllers[page] = controller;
  }

  void onVisibilityChanged(bool value) {
    controller.setHideOverlay(value);
  }

  void onZoomUpdated(bool zoom) {
    controller.setEnableSwiping(!zoom);
  }

  void onImageTap() {
    if (controller.slideshow.value) {
      controller.stopSlideshow();
    }
    controller.toggleOverlay();
  }
}
