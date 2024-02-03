// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/video/videos_provider.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
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
    this.showSourceTile = true,
    this.onPageChanged,
    this.sliverRelatedPostsBuilder,
    this.commentsBuilder,
    this.poolTileBuilder,
    this.statsTileBuilder,
    this.fileDetailsBuilder,
  });

  final int initialIndex;
  final List<T> posts;
  final void Function(int page) onExit;
  final void Function(String tag) onTagTap;
  final void Function(T post)? onExpanded;
  final void Function(T post)? onPageChanged;
  final String Function(T post) swipeImageUrlBuilder;
  final String? Function(T post, int currentPage)? placeholderImageUrlBuilder;
  final Widget Function(BuildContext context, T post)? toolbarBuilder;
  final Widget Function(BuildContext context, T post)? sliverArtistPostsBuilder;
  final Widget Function(BuildContext context, T post)?
      sliverCharacterPostsBuilder;
  final Widget Function(BuildContext context, T post)? tagListBuilder;
  final Widget Function(BuildContext context, T post)? infoBuilder;
  final Widget Function(BuildContext context, T post)? artistInfoBuilder;
  final Widget Function(BuildContext context, T post)? commentsBuilder;
  final Widget Function(BuildContext context, T post)? poolTileBuilder;
  final Widget Function(BuildContext context, T post)? statsTileBuilder;
  final Widget Function(BuildContext context, T post)? fileDetailsBuilder;

  final Widget Function(BuildContext context, T post)?
      sliverRelatedPostsBuilder;
  final List<Widget> Function(int currentPage, bool expanded, T post)?
      topRightButtonsBuilder;
  final List<Widget> Function(BoxConstraints constraints, T post)?
      imageOverlayBuilder;
  final bool showSourceTile;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>>
    with PostDetailsPageMixin<PostDetailsPageScaffold<T>, T> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialIndex].isVideo);

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
    return DetailsPage(
      controller: controller,
      intitialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: (page) {
        onSwiped(page);
        widget.onPageChanged?.call(posts[page]);
      },
      bottomSheet: (page) {
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
                    onSeek: (position) => onVideoSeekTo(position, page),
                    onSoundToggle: (value) => ref.setGlobalVideoSound(value),
                  ),
                ),
              ),
            if (widget.infoBuilder != null)
              widget.infoBuilder!(context, posts[page]),
            Container(
              color: context.colorScheme.surface,
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              child: widget.toolbarBuilder != null
                  ? widget.toolbarBuilder!(context, posts[page])
                  : SimplePostActionToolbar(post: posts[page]),
            ),
          ],
        );

        return widget.infoBuilder != null
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
      },
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].isVideo
            ? posts[page].videoThumbnailUrl
            : widget.swipeImageUrlBuilder(posts[page]),
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets =
            _buildWidgets(context, expanded, page, currentPage, ref);

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
              if (widget.sliverRelatedPostsBuilder != null &&
                  expanded &&
                  page == currentPage)
                widget.sliverRelatedPostsBuilder!(context, posts[page]),
              if (widget.sliverArtistPostsBuilder != null &&
                  expanded &&
                  page == currentPage)
                widget.sliverArtistPostsBuilder!(context, posts[page]),
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
              ? widget.topRightButtonsBuilder!(page, expanded, posts[page])
              : [
                  GeneralMoreActionButton(post: widget.posts[page]),
                ],
      onExpanded: (currentPage) => widget.onExpanded?.call(posts[currentPage]),
    );
  }

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
    WidgetRef ref,
  ) {
    final post = posts[page];
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = PostMedia(
      inFocus: !expanded && page == currentPage,
      post: post,
      imageUrl: widget.swipeImageUrlBuilder(post),
      placeholderImageUrl: widget.placeholderImageUrlBuilder != null
          ? widget.placeholderImageUrlBuilder!(post, currentPage)
          : post.thumbnailImageUrl,
      onImageTap: onImageTap,
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
      if (!expandedOnCurrentPage)
        SizedBox(
          height: context.screenHeight - MediaQuery.viewPaddingOf(context).top,
          child: RepaintBoundary(child: media),
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage) SizedBox(height: context.screenHeight),
      if (expandedOnCurrentPage) ...[
        if (widget.poolTileBuilder != null)
          widget.poolTileBuilder!(context, post),
        if (widget.infoBuilder != null) widget.infoBuilder!(context, post),
        const Divider(height: 8, thickness: 0.5),
        if (widget.toolbarBuilder != null)
          widget.toolbarBuilder!(context, post)
        else
          SimplePostActionToolbar(post: post),
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
              tags: post.tags,
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
        if (widget.showSourceTile)
          post.source.whenWeb(
            (source) => SourceSection(source: source),
            () => const SizedBox.shrink(),
          ),
        if (widget.commentsBuilder != null)
          widget.commentsBuilder!(context, post),
      ],
    ];
  }
}
