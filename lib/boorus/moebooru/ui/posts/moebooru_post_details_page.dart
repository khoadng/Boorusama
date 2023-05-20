// Flutter imports:
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_video_progress_bar.dart';
import 'package:boorusama/core/ui/details_page.dart';
import 'package:boorusama/core/ui/embedded_webview_webm.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/post_media_item.dart';
import 'package:boorusama/core/ui/post_video.dart';
import 'package:boorusama/core/ui/posts.dart';
import 'package:boorusama/core/ui/source_section.dart';
import 'package:boorusama/core/ui/swipe_target_image.dart';
import 'package:boorusama/core/ui/tags/basic_tag_list.dart';

class MoebooruPostDetailsPage extends ConsumerStatefulWidget {
  const MoebooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialPage,
    required this.fullscreen,
    // required this.onPageChanged,
    // required this.onCachedImagePathUpdate,
    required this.onExit,
  });

  final List<Post> posts;
  final int initialPage;
  final bool fullscreen;
  // final void Function(int page) onPageChanged;
  // final void Function(String? imagePath) onCachedImagePathUpdate;
  final void Function(int page) onExit;

  static MaterialPageRoute routeOf(
    BuildContext context,
    WidgetRef ref, {
    required List<Post> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
    required Settings settings,
  }) {
    return MaterialPageRoute(
      builder: (_) {
        return MoebooruProvider.of(
          context,
          ref,
          builder: (context) => MoebooruPostDetailsPage(
            posts: posts,
            onExit: (page) => scrollController?.scrollToIndex(page),
            initialPage: initialIndex,
            fullscreen: settings.detailsDisplay == DetailsDisplay.imageFocus,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<MoebooruPostDetailsPage> createState() =>
      _MoebooruPostDetailsPageState();
}

class _MoebooruPostDetailsPageState
    extends ConsumerState<MoebooruPostDetailsPage>
    with PostDetailsPageMixin<MoebooruPostDetailsPage, Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialPage].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<Post> get posts => widget.posts;

  @override
  int get initialPage => widget.initialPage;

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      intitialIndex: widget.initialPage,
      onExit: widget.onExit,
      onPageChanged: onSwiped,
      bottomSheet: (page) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (posts[page].isVideo)
            ValueListenableBuilder<VideoProgress>(
              valueListenable: videoProgress,
              builder: (_, progress, __) =>
                  BooruVideoProgressBar(progress: progress),
            ),
          MoebooruPostActionToolbar(post: posts[page]),
        ],
      ),
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].thumbnailImageUrl,
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets = _buildWidgets(context, expanded, page, currentPage);

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
      topRightButtonsBuilder: (currentPage) => [
        MoebooruMoreActionButton(
          post: widget.posts[currentPage],
        ),
      ],
    );
  }

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
  ) {
    final post = posts[page];
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = post.isVideo
        ? extension(post.sampleImageUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: post.sampleImageUrl,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
              )
            : BooruVideo(
                url: post.sampleImageUrl,
                aspectRatio: post.aspectRatio,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
              )
        : InteractiveBooruImage(
            useHero: page == currentPage,
            heroTag: "${post.id}_hero",
            aspectRatio: post.aspectRatio,
            imageUrl: post.sampleImageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: context.read<PreviewImageCacheManager>(),
            width: post.width,
            height: post.height,
            onZoomUpdated: onZoomUpdated,
          );

    return [
      if (!expandedOnCurrentPage)
        SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top,
          child: RepaintBoundary(child: media),
        )
      else if (post.isVideo)
        BooruImage(
          imageUrl: post.thumbnailImageUrl,
          fit: BoxFit.contain,
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        Padding(
          padding: const EdgeInsets.all(8),
          child: BasicTagList(
            tags: post.tags,
            onTap: (tag) => goToMoebooruSearchPage(ref, context, tag: tag),
          ),
        ),
        const Divider(
          thickness: 1.5,
          height: 4,
        ),
        FileDetailsSection(
          post: post,
        ),
        post.source.whenWeb(
          (source) => SourceSection(url: source.url),
          () => const SizedBox.shrink(),
        ),
      ],
    ];
  }
}
