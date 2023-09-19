// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/simple_post_action_toolbar.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';

class SimplePostDetailsPage extends ConsumerStatefulWidget {
  const SimplePostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    required this.onTagTap,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int page) onExit;
  final void Function(String tag) onTagTap;

  @override
  ConsumerState<SimplePostDetailsPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<SimplePostDetailsPage>
    with PostDetailsPageMixin<SimplePostDetailsPage, Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialIndex].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<Post> get posts => widget.posts;

  @override
  int get initialPage => widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      controller: controller,
      intitialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: onSwiped,
      bottomSheet: (page) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (posts[page].isVideo)
            ValueListenableBuilder(
              valueListenable: videoProgress,
              builder: (_, progress, __) => BooruVideoProgressBar(
                progress: progress,
                onSeek: (position) => onVideoSeekTo(position, page),
              ),
            ),
          SimplePostActionToolbar(post: posts[page]),
        ],
      ),
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].thumbnailImageUrl,
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
            ],
          ),
        );
      },
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (page, expanded) => [
        GeneralMoreActionButton(post: widget.posts[page]),
      ],
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
      imageUrl: post.thumbnailFromSettings(ref.read(settingsProvider)),
      placeholderImageUrl: post.thumbnailImageUrl,
      onImageTap: onImageTap,
      onCurrentVideoPositionChanged: onCurrentPositionChanged,
      onVideoVisibilityChanged: onVisibilityChanged,
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
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top,
          child: RepaintBoundary(child: media),
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        BasicTagList(
          tags: post.tags,
          onTap: widget.onTagTap,
        ),
        const Divider(height: 8, thickness: 1),
        FileDetailsSection(
          post: post,
        ),
        post.source.whenWeb(
          (source) => SourceSection(source: source),
          () => const SizedBox.shrink(),
        ),
      ],
    ];
  }
}
