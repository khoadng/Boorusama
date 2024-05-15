// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
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

class PostFromIndex extends InheritedWidget {
  const PostFromIndex({
    super.key,
    required this.post,
    required super.child,
  });

  final Post Function(int index) post;

  static Post of(BuildContext context, int index) {
    final post = context.dependOnInheritedWidgetOfExactType<PostFromIndex>();

    if (post == null) {
      throw FlutterError('No PostFromIndex found in context');
    }

    return post.post(index);
  }

  @override
  bool updateShouldNotify(PostFromIndex oldWidget) {
    return post != oldWidget.post;
  }
}

class CurrentPost extends InheritedWidget {
  const CurrentPost({
    super.key,
    required this.post,
    required super.child,
  });

  final Post post;

  static T of<T extends Post>(BuildContext context) {
    final post = context.dependOnInheritedWidgetOfExactType<CurrentPost>();

    if (post == null) {
      throw FlutterError('No CurrentPost found in context');
    }

    return post.post as T;
  }

  @override
  bool updateShouldNotify(CurrentPost oldWidget) {
    return post != oldWidget.post;
  }
}

class NextPost extends InheritedWidget {
  const NextPost({
    super.key,
    required this.post,
    required super.child,
  });

  final Post? post;

  static T? of<T extends Post>(BuildContext context) {
    final post = context.dependOnInheritedWidgetOfExactType<NextPost>();

    if (post == null) {
      throw FlutterError('No NextPost found in context');
    }

    return post.post as T?;
  }

  @override
  bool updateShouldNotify(NextPost oldWidget) {
    return post != oldWidget.post;
  }
}

class CurrentPage extends InheritedWidget {
  const CurrentPage({
    super.key,
    required this.currentPage,
    required super.child,
  });

  final int currentPage;

  static int of(BuildContext context) {
    final currentPage =
        context.dependOnInheritedWidgetOfExactType<CurrentPage>();
    return currentPage?.currentPage ?? 0;
  }

  @override
  bool updateShouldNotify(CurrentPage oldWidget) {
    return currentPage != oldWidget.currentPage;
  }
}

class PageExpanded extends InheritedWidget {
  const PageExpanded({
    super.key,
    required this.expanded,
    required super.child,
  });

  final bool expanded;

  static bool of(BuildContext context) {
    final expanded = context.dependOnInheritedWidgetOfExactType<PageExpanded>();
    return expanded?.expanded ?? false;
  }

  @override
  bool updateShouldNotify(PageExpanded oldWidget) {
    return expanded != oldWidget.expanded;
  }
}

class PageSwipe extends InheritedWidget {
  const PageSwipe({
    super.key,
    required this.pageSwipe,
    required super.child,
  });

  final bool pageSwipe;

  static bool of(BuildContext context) {
    final pageSwipe = context.dependOnInheritedWidgetOfExactType<PageSwipe>();
    return pageSwipe?.pageSwipe ?? true;
  }

  @override
  bool updateShouldNotify(PageSwipe oldWidget) {
    return pageSwipe != oldWidget.pageSwipe;
  }
}

class PostDetailsContext extends InheritedWidget {
  const PostDetailsContext({
    super.key,
    required this.controller,
    required this.page,
    required this.pageCount,
    required this.sliverArtistPostsBuilder,
    required this.sliverRelatedPostsBuilder,
    required this.sliverCharacterPostsBuilder,
    required this.imageOverlayBuilder,
    required this.artistInfoBuilder,
    required this.tagListBuilder,
    required this.statsTileBuilder,
    required this.fileDetailsBuilder,
    required this.sourceSectionBuilder,
    required this.poolTileBuilder,
    required this.commentsBuilder,
    required this.onTagTap,
    required this.swipeImageUrlBuilder,
    required this.placeholderImageUrlBuilder,
    required this.initialIndex,
    required this.onExit,
    required this.onExpanded,
    required this.toolbarBuilder,
    required this.infoBuilder,
    required this.topRightButtonsBuilder,
    required super.child,
  });

  final int page;
  final int pageCount;
  final List<Widget>? sliverArtistPostsBuilder;
  final Widget? sliverRelatedPostsBuilder;
  final Widget? sliverCharacterPostsBuilder;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final Widget? artistInfoBuilder;
  final Widget tagListBuilder;
  final Widget? statsTileBuilder;
  final Widget fileDetailsBuilder;
  final Widget sourceSectionBuilder;
  final Widget? poolTileBuilder;
  final Widget? commentsBuilder;

  final void Function(String tag) onTagTap;

  final String Function(int page) swipeImageUrlBuilder;
  final String? Function(int page)? placeholderImageUrlBuilder;

  final DetailsPageController controller;
  final int initialIndex;
  final void Function() onExit;
  final void Function()? onExpanded;
  final Widget? toolbarBuilder;
  final Widget? infoBuilder;
  final List<Widget>? topRightButtonsBuilder;

  static PostDetailsContext of(BuildContext context) {
    final controller =
        context.dependOnInheritedWidgetOfExactType<PostDetailsContext>();

    if (controller == null) {
      throw FlutterError('No PostDetailsContext found in context');
    }

    return controller;
  }

  @override
  bool updateShouldNotify(PostDetailsContext oldWidget) {
    return page != oldWidget.page;
  }
}

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
    extends ConsumerState<PostDetailsPageScaffold<T>> {
  late final _controller = DetailsPageController(
    initialPage: widget.initialIndex,
    swipeDownToDismiss: !widget.posts[widget.initialIndex].isVideo,
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
  );

  late var _page = _controller.currentPage.value;
  late var _expanded = _controller.expanded.value;
  late var _pageSwipe = _controller.pageSwipe;

  @override
  void initState() {
    super.initState();
    _controller.currentPage.addListener(_onPageChanged);
    _controller.expanded.addListener(() {
      setState(() {
        _expanded = _controller.expanded.value;
      });
    });

    _controller.addListener(() {
      if (_pageSwipe != _controller.pageSwipe) {
        setState(() {
          _pageSwipe = _controller.pageSwipe;
        });
      }
    });
  }

  void _onPageChanged() {
    final page = _controller.currentPage.value;

    setState(() {
      _page = page;
    });

    ref
        .read(postShareProvider(widget.posts[page]).notifier)
        .updateInformation(widget.posts[page]);

    widget.onPageChangeIndexed?.call(page);
    widget.onPageChanged?.call(widget.posts[page]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.posts[_page];
    final nextPost =
        widget.posts.length > _page + 1 ? widget.posts[_page + 1] : null;

    return CurrentPage(
      currentPage: _page,
      child: CurrentPost(
        post: post,
        child: NextPost(
          post: nextPost,
          child: PostFromIndex(
            post: (index) => widget.posts[index],
            child: PageExpanded(
              expanded: _expanded,
              child: PageSwipe(
                pageSwipe: _pageSwipe,
                child: PostDetailsContext(
                  initialIndex: widget.initialIndex,
                  pageCount: widget.posts.length,
                  onExit: () => widget.onExit(_page),
                  onTagTap: widget.onTagTap,
                  toolbarBuilder: widget.toolbarBuilder != null
                      ? widget.toolbarBuilder!(context, post)
                      : null,
                  sliverArtistPostsBuilder:
                      widget.sliverArtistPostsBuilder != null && _expanded
                          ? widget.sliverArtistPostsBuilder!(context, post)
                          : null,
                  sliverCharacterPostsBuilder:
                      widget.sliverCharacterPostsBuilder != null && _expanded
                          ? widget.sliverCharacterPostsBuilder!(context, post)
                          : null,
                  onExpanded: widget.onExpanded != null
                      ? () => widget.onExpanded!(post)
                      : null,
                  tagListBuilder: widget.tagListBuilder != null && _expanded
                      ? widget.tagListBuilder!(context, post)
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: BasicTagList(
                            tags: post.tags.toList(),
                            onTap: widget.onTagTap,
                          ),
                        ),
                  infoBuilder: widget.infoBuilder != null
                      ? widget.infoBuilder!(context, post)
                      : null,
                  swipeImageUrlBuilder: (page) =>
                      widget.swipeImageUrlBuilder(widget.posts[page]),
                  topRightButtonsBuilder: widget.topRightButtonsBuilder != null
                      ? widget.topRightButtonsBuilder!(
                          _page,
                          _expanded,
                          post,
                          _controller,
                        )
                      : null,
                  placeholderImageUrlBuilder:
                      widget.placeholderImageUrlBuilder != null
                          ? (page) =>
                              widget.placeholderImageUrlBuilder!(post, page)
                          : null,
                  imageOverlayBuilder: (constraints) =>
                      widget.imageOverlayBuilder != null
                          ? widget.imageOverlayBuilder!(constraints, post)
                          : [],
                  artistInfoBuilder:
                      widget.artistInfoBuilder != null && _expanded
                          ? widget.artistInfoBuilder!(context, post)
                          : null,
                  sliverRelatedPostsBuilder:
                      widget.sliverRelatedPostsBuilder != null && _expanded
                          ? widget.sliverRelatedPostsBuilder!(context, post)
                          : null,
                  commentsBuilder: widget.commentsBuilder != null && _expanded
                      ? widget.commentsBuilder!(context, post)
                      : null,
                  poolTileBuilder: widget.poolTileBuilder != null && _expanded
                      ? widget.poolTileBuilder!(context, post)
                      : null,
                  statsTileBuilder: widget.statsTileBuilder != null && _expanded
                      ? widget.statsTileBuilder!(context, post)
                      : null,
                  fileDetailsBuilder:
                      widget.fileDetailsBuilder != null && _expanded
                          ? widget.fileDetailsBuilder!(context, post)
                          : FileDetailsSection(
                              post: post,
                              rating: post.rating,
                            ),
                  sourceSectionBuilder:
                      widget.sourceSectionBuilder != null && _expanded
                          ? widget.sourceSectionBuilder!(context, post)
                          : post.source.whenWeb(
                              (source) => SourceSection(source: source),
                              () => const SizedBox.shrink(),
                            ),
                  controller: _controller,
                  page: _page,
                  child: const PostDetailsPageScaffoldInternal(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostDetailsPageScaffoldInternal<T extends Post>
    extends ConsumerStatefulWidget {
  const PostDetailsPageScaffoldInternal({
    super.key,
  });

  @override
  ConsumerState<PostDetailsPageScaffoldInternal<T>> createState() =>
      _PostDetailPageScaffoldInternaltate<T>();
}

class _PostDetailPageScaffoldInternaltate<T extends Post>
    extends ConsumerState<PostDetailsPageScaffoldInternal<T>>
    with PostDetailsPageMixin<PostDetailsPageScaffoldInternal<T>, T> {
  @override
  DetailsPageController get controller => _controller!;

  DetailsPageController? _controller;
  int _initialPage = 0;
  T? _post;

  void _onPageChanged() {
    final page = controller.currentPage.value;

    onSwiped(page);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = PostDetailsContext.of(context).controller;
    _controller?.currentPage.addListener(_onPageChanged);
    _initialPage = PostDetailsContext.of(context).initialIndex;
    _post = CurrentPost.of(context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.currentPage.removeListener(_onPageChanged);
  }

  @override
  T get post => _post!;

  @override
  int get initialPage => _initialPage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.slideshow,
      builder: (context, slideshow, child) => GestureDetector(
        behavior: slideshow ? HitTestBehavior.opaque : null,
        onTap: () => controller.stopSlideshow(),
        child: IgnorePointer(
          ignoring: slideshow,
          child: child!,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => _build(constraints),
      ),
    );
  }

  Widget _build(BoxConstraints constraints) {
    final widget = PostDetailsContext.of(context);

    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final sharedChild = Column(
      children: [
        if (widget.infoBuilder != null)
          constraints.maxHeight > 450
              ? widget.infoBuilder!
              : const SizedBox.shrink(),
        widget.toolbarBuilder != null
            ? widget.toolbarBuilder!
            : SimplePostActionToolbar(post: post),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) => DetailsPage(
        currentSettings: () => ref.read(settingsProvider),
        controller: controller,
        intitialIndex: widget.initialIndex,
        onExit: widget.onExit,
        onSwipeDownEnd: booruBuilder?.canHandlePostGesture(
                      GestureType.swipeDown,
                      config.postGestures?.fullview,
                    ) ==
                    true &&
                postGesturesHandler != null
            ? () => postGesturesHandler(
                  ref,
                  config.postGestures?.fullview?.swipeDown,
                  post,
                )
            : null,
        bottomSheet: PostDetailsBottomSheet(
          videoProgress: videoProgress,
          onVideoSeekTo: onVideoSeekTo,
          sharedChild: sharedChild,
        ),
        targetSwipeDown: _SwipeImage(
          swipeImageUrlBuilder: (_) =>
              widget.swipeImageUrlBuilder(CurrentPage.of(context)),
        ),
        expandedBuilder: (context, page) {
          return PostDetailsContentContext(
            page: page,
            sharedChild: sharedChild,
            placeholderImageUrlBuilder: (currentPage) =>
                widget.placeholderImageUrlBuilder != null
                    ? widget.placeholderImageUrlBuilder!(currentPage)
                    : null,
            onTagTap: widget.onTagTap,
            onCurrentPositionChanged: onCurrentPositionChanged,
            onVisibilityChanged: onVisibilityChanged,
            onZoomUpdated: onZoomUpdated,
            onImageTap: onImageTap,
            onVideoPlayerCreated: onVideoPlayerCreated,
            onWebmVideoPlayerCreated: onWebmVideoPlayerCreated,
            child: const PostDetailsContent(),
          );
        },
        pageCount: widget.pageCount,
        topRightButtonsBuilder: widget.topRightButtonsBuilder != null
            ? widget.topRightButtonsBuilder!
            : [
                GeneralMoreActionButton(
                  post: post,
                  onStartSlideshow: () => controller.startSlideshow(),
                ),
              ],
        onExpanded: () =>
            widget.onExpanded != null ? () => widget.onExpanded!() : null,
      ),
    );
  }
}

class PostDetailsBottomSheet<T extends Post> extends ConsumerWidget {
  const PostDetailsBottomSheet({
    super.key,
    required this.videoProgress,
    required this.onVideoSeekTo,
    required this.sharedChild,
  });
  final Widget sharedChild;
  final ValueNotifier<VideoProgress> videoProgress;
  final void Function(Duration position, int page) onVideoSeekTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = CurrentPage.of(context);
    final post = CurrentPost.of<T>(context);
    final infoBuilder = PostDetailsContext.of(context).infoBuilder;

    final bottomSheet = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (post.isVideo)
          ValueListenableBuilder(
            valueListenable: videoProgress,
            builder: (_, progress, __) => VideoSoundScope(
              builder: (context, soundOn) => BooruVideoProgressBar(
                soundOn: soundOn,
                progress: progress,
                playbackSpeed: ref.watchPlaybackSpeed(post.videoUrl),
                onSeek: (position) => onVideoSeekTo(position, page),
                onSpeedChanged: (speed) =>
                    ref.setPlaybackSpeed(post.videoUrl, speed),
                onSoundToggle: (value) => ref.setGlobalVideoSound(value),
              ),
            ),
          ),
        Container(
          color: context.colorScheme.surface,
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: sharedChild,
        ),
      ],
    );

    return infoBuilder != null
        ? Container(
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor.withOpacity(0.8),
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
  }
}

class PostDetailsContentContext extends InheritedWidget {
  const PostDetailsContentContext({
    super.key,
    required this.page,
    required this.sharedChild,
    required this.placeholderImageUrlBuilder,
    required this.onCurrentPositionChanged,
    required this.onVisibilityChanged,
    required this.onZoomUpdated,
    required this.onImageTap,
    required this.onVideoPlayerCreated,
    required this.onWebmVideoPlayerCreated,
    required this.onTagTap,
    required super.child,
  });

  final int page;
  final Widget sharedChild;
  final String? Function(int page) placeholderImageUrlBuilder;
  final void Function(double, double, String) onCurrentPositionChanged;
  final void Function(bool visible) onVisibilityChanged;
  final void Function(bool zoom) onZoomUpdated;
  final void Function() onImageTap;
  final void Function(VideoPlayerController controller, int page)
      onVideoPlayerCreated;
  final void Function(WebmVideoController controller, int page)
      onWebmVideoPlayerCreated;

  final void Function(String tag) onTagTap;

  static PostDetailsContentContext of(BuildContext context) {
    final controller =
        context.dependOnInheritedWidgetOfExactType<PostDetailsContentContext>();

    if (controller == null) {
      throw FlutterError('No PostDetailsContentContext found in context');
    }

    return controller;
  }

  @override
  bool updateShouldNotify(PostDetailsContentContext oldWidget) {
    return page != oldWidget.page;
  }
}

class PostDetailsContent<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsContent({
    super.key,
  });

  @override
  ConsumerState<PostDetailsContent<T>> createState() =>
      _PostDetailsContentState();
}

class _PostDetailsContentState<T extends Post>
    extends ConsumerState<PostDetailsContent<T>> {
  @override
  Widget build(BuildContext context) {
    final state = PostDetailsContentContext.of(context);
    final widget = PostDetailsContext.of(context);

    final currentPage = CurrentPage.of(context);
    final page = state.page;
    final expanded = PageExpanded.of(context);
    final enableSwipe = PageSwipe.of(context);

    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;

    final widgets = _buildWidgets(
      context,
      expanded,
      state.page,
      currentPage,
      ref,
      booruBuilder,
      postGesturesHandler,
      state.sharedChild,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        physics: enableSwipe ? null : const NeverScrollableScrollPhysics(),
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
              ...widget.sliverArtistPostsBuilder!,
          if (widget.sliverRelatedPostsBuilder != null &&
              ref.watch(_visibleProvider(currentPage)) &&
              expanded &&
              page == currentPage)
            widget.sliverRelatedPostsBuilder!,
          if (widget.sliverCharacterPostsBuilder != null &&
              expanded &&
              page == currentPage)
            widget.sliverCharacterPostsBuilder!,
          SliverSizedBox(
            height: MediaQuery.paddingOf(context).bottom + 72,
          ),
        ],
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
    final state = PostDetailsContentContext.of(context);
    final widget = PostDetailsContext.of(context);
    final nextPost = NextPost.of<T>(context);
    final expandedOnCurrentPage = expanded && page == currentPage;
    final postFromIndex = PostFromIndex.of(context, page);
    final media = PostMedia(
      inFocus: !expanded && page == currentPage,
      post: postFromIndex,
      imageUrl: widget.swipeImageUrlBuilder(page),
      placeholderImageUrl: widget.placeholderImageUrlBuilder != null
          ? widget.placeholderImageUrlBuilder!(page)
          : postFromIndex.thumbnailImageUrl,
      onImageTap: state.onImageTap,
      onDoubleTap: booruBuilder?.canHandlePostGesture(
                    GestureType.doubleTap,
                    ref.watchConfig.postGestures?.fullview,
                  ) ==
                  true &&
              postDetailsGesturesHandler != null
          ? () => postDetailsGesturesHandler(
                ref,
                ref.watchConfig.postGestures?.fullview?.doubleTap,
                postFromIndex,
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
                postFromIndex,
              )
          : null,
      onCurrentVideoPositionChanged: state.onCurrentPositionChanged,
      onVideoVisibilityChanged: state.onVisibilityChanged,
      imageOverlayBuilder: (constraints) => widget.imageOverlayBuilder != null
          ? widget.imageOverlayBuilder!(constraints)
          : [],
      useHero: page == currentPage,
      onImageZoomUpdated: state.onZoomUpdated,
      onVideoPlayerCreated: (controller) =>
          state.onVideoPlayerCreated(controller, page),
      onWebmVideoPlayerCreated: (controller) =>
          state.onWebmVideoPlayerCreated(controller, page),
      autoPlay: true,
    );

    return [
      // preload next image only, not the post itself
      if (nextPost != null && !nextPost.isVideo)
        Offstage(
          offstage: true,
          child: ExtendedImage.network(
            widget.swipeImageUrlBuilder(page + 1),
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
        if (widget.poolTileBuilder != null) widget.poolTileBuilder!,
        if (sharedChild != null) sharedChild,
        if (widget.artistInfoBuilder != null) ...[
          const Divider(height: 8, thickness: 0.5),
          widget.artistInfoBuilder!,
        ],
        if (widget.statsTileBuilder != null) ...[
          const SizedBox(height: 12),
          widget.statsTileBuilder!,
        ],
        const Divider(height: 8, thickness: 0.5),
        widget.tagListBuilder,
        widget.fileDetailsBuilder,
        const Divider(height: 8, thickness: 0.5),
        widget.sourceSectionBuilder,
        if (widget.commentsBuilder != null) widget.commentsBuilder!,
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

class _SwipeImage<T extends Post> extends StatelessWidget {
  const _SwipeImage({
    super.key,
    required this.swipeImageUrlBuilder,
  });

  final String Function(T post) swipeImageUrlBuilder;

  @override
  Widget build(BuildContext context) {
    final post = CurrentPost.of<T>(context);

    return SwipeTargetImage(
      imageUrl:
          post.isVideo ? post.videoThumbnailUrl : swipeImageUrlBuilder(post),
      aspectRatio: post.aspectRatio,
    );
  }
}

final _visibleProvider =
    StateProvider.autoDispose.family<bool, int>((ref, key) => false);
