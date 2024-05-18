// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/video/videos_provider.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    required this.onTagTap,
    this.toolbarBuilder,
    this.sliverArtistPostsBuilder,
    this.sliverCharacterPostsBuilder,
    this.onExpanded,
    this.tagListBuilder,
    this.infoBuilder,
    required this.swipeImageUrlBuilder,
    this.topRightButtonsBuilder,
    this.placeholderImageUrlBuilder,
    this.imageOverlayBuilder,
    this.artistInfoBuilder,
    this.onPageChanged,
    this.onPageChangeIndexed,
    this.sliverRelatedPostsBuilder,
    this.commentsBuilder,
    this.poolTileBuilder,
    this.statsTileBuilder,
    this.fileDetailsBuilder,
    this.sourceSectionBuilder,
  });

  final int initialIndex;
  final List<T> posts;
  final void Function(int page) onExit;
  final void Function(String tag) onTagTap;
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

  final Widget Function(BuildContext context, T post)?
      sliverRelatedPostsBuilder;
  final List<Widget> Function(int currentPage, bool expanded, T post,
      DetailsPageController controller)? topRightButtonsBuilder;
  final List<Widget> Function(BoxConstraints constraints, T post)?
      imageOverlayBuilder;

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
          final widgets = _buildWidgets(
            context,
            expanded,
            page,
            currentPage,
            ref,
            booruBuilder,
            postGesturesHandler,
            sharedChild,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomScrollView(
              physics:
                  enableSwipe ? null : const NeverScrollableScrollPhysics(),
              controller: PageContentScrollController.of(context),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => widgets[index],
                    childCount: widgets.length,
                  ),
                ),
                if (expanded && page == currentPage)
                  if (widget.sliverArtistPostsBuilder != null)
                    ...widget.sliverArtistPostsBuilder!(context, posts[page]),
                if (widget.sliverRelatedPostsBuilder != null &&
                    ref.watch(_visibleProvider(currentPage)) &&
                    expanded &&
                    page == currentPage)
                  widget.sliverRelatedPostsBuilder!(context, posts[page]),
                if (widget.sliverCharacterPostsBuilder != null &&
                    expanded &&
                    page == currentPage)
                  widget.sliverCharacterPostsBuilder!(context, posts[page]),
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

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
    WidgetRef ref,
    BooruBuilder? booruBuilder,
    PostGestureHandlerBuilder? postDetailsGesturesHandler,
    Widget? sharedChild,
  ) {
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
              postDetailsGesturesHandler != null
          ? () => postDetailsGesturesHandler(
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
              postDetailsGesturesHandler != null
          ? () => postDetailsGesturesHandler(
                ref,
                ref.watchConfig.postGestures?.fullview?.longPress,
                post,
              )
          : null,
      onCurrentVideoPositionChanged: onCurrentPositionChanged,
      onVideoVisibilityChanged: onVisibilityChanged,
      imageOverlayBuilder: (constraints) => widget.imageOverlayBuilder != null
          ? widget.imageOverlayBuilder!(constraints, post)
          : [],
      useHero: page == currentPage,
      onImageZoomUpdated: onZoomUpdated,
      onVideoPlayerCreated: (controller) =>
          onVideoPlayerCreated(controller, page),
      onWebmVideoPlayerCreated: (controller) =>
          onWebmVideoPlayerCreated(controller, page),
      autoPlay: true,
    );

    return [
      // preload next image only, not the post itself
      if (nextPost != null && !nextPost.isVideo)
        Offstage(
          offstage: true,
          child: ExtendedImage.network(
            widget.swipeImageUrlBuilder(nextPost),
            width: 1,
            height: 1,
            cacheHeight: 10,
            cacheWidth: 10,
            cache: true,
          ),
        ),
      if (!expandedOnCurrentPage)
        SizedBox(
          height: context.screenHeight - MediaQuery.viewPaddingOf(context).top,
          child: media,
        )
      else
        media,
      if (!expandedOnCurrentPage) SizedBox(height: context.screenHeight),
      if (expandedOnCurrentPage) ...[
        if (widget.poolTileBuilder != null)
          widget.poolTileBuilder!(context, post),
        if (sharedChild != null) sharedChild,
        if (widget.artistInfoBuilder != null) ...[
          const Divider(height: 8, thickness: 0.5),
          widget.artistInfoBuilder!(context, post),
        ],
        if (widget.statsTileBuilder != null) ...[
          const SizedBox(height: 12),
          widget.statsTileBuilder!(context, post),
        ],
        const Divider(height: 8, thickness: 0.5),
        if (widget.tagListBuilder != null)
          widget.tagListBuilder!(context, post)
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: BasicTagList(
              tags: post.tags.toList(),
              onTap: widget.onTagTap,
            ),
          ),
        if (widget.fileDetailsBuilder != null)
          widget.fileDetailsBuilder!(context, post)
        else
          FileDetailsSection(
            post: post,
            rating: post.rating,
          ),
        const Divider(height: 8, thickness: 0.5),
        widget.sourceSectionBuilder != null
            ? widget.sourceSectionBuilder!(context, post)
            : post.source.whenWeb(
                (source) => SourceSection(source: source),
                () => const SizedBox.shrink(),
              ),
        if (widget.commentsBuilder != null)
          widget.commentsBuilder!(context, post),
        VisibilityDetector(
          key: ValueKey(page),
          onVisibilityChanged: (info) {
            if (!mounted) return;

            final visibilityState = ref.read(_visibleProvider(page));
            if (!visibilityState && info.visibleFraction == 1.0) {
              ref.read(_visibleProvider(page).notifier).state = true;
            }
          },
          child: const SizedBox(
            height: 4,
          ),
        ),
      ],
    ];
  }
}

final _visibleProvider =
    StateProvider.autoDispose.family<bool, int>((ref, key) => false);
