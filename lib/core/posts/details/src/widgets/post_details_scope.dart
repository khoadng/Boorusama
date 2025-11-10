// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../settings/providers.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/types.dart';
import '../types/inherited_post.dart';
import '../types/post_details.dart';
import 'post_details_controller.dart';
import 'post_details_page_view_scope.dart';

class PostDetailsScope<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsScope({
    required this.initialIndex,
    required this.initialThumbnailUrl,
    required this.posts,
    required this.dislclaimer,
    required this.child,
    required this.scrollController,
    super.key,
  });

  final int initialIndex;
  final String? initialThumbnailUrl;
  final List<T> posts;
  final String? dislclaimer;
  final AutoScrollController? scrollController;
  final Widget child;

  @override
  ConsumerState<PostDetailsScope<T>> createState() =>
      _PostDetailsLayoutSwitcherState<T>();
}

class _PostDetailsLayoutSwitcherState<T extends Post>
    extends ConsumerState<PostDetailsScope<T>> {
  late final PostDetailsController<T> _controller;
  late final PostDetailsPageViewController _pageViewController;

  @override
  void initState() {
    super.initState();

    final initialPage = widget.initialIndex;
    final settings = ref.read(settingsProvider);
    final viewerSettings = ref.read(imageViewerSettingsProvider);

    final reduceAnimations = settings.reduceAnimations;
    final hideOverlay = viewerSettings.postDetailsOverlayInitialState.isHide;
    final slideshowOptions = toSlideShowOptions(viewerSettings);
    final hoverToControlOverlay = widget.posts[initialPage].isVideo;

    _controller = PostDetailsController<T>(
      scrollController: widget.scrollController,
      initialPage: initialPage,
      initialThumbnailUrl: widget.initialThumbnailUrl,
      posts: widget.posts,
      reduceAnimations: reduceAnimations,
      dislclaimer: widget.dislclaimer,
      doubleTapSeekDuration: viewerSettings.doubleTapSeekDuration,
    );

    _pageViewController = PostDetailsPageViewController(
      initialPage: initialPage,
      initialHideOverlay: hideOverlay,
      slideshowOptions: slideshowOptions,
      hoverToControlOverlay: hoverToControlOverlay,
      checkIfLargeScreen: () => context.isLargeScreen,
      totalPage: widget.posts.length,
      disableAnimation: reduceAnimations,
      onBeforeSlideshowAdvance: (currentPage, nextPage) async {
        if (viewerSettings.slideshowVideoBehavior.isWaitForCompletion) {
          final currentPost = widget.posts[currentPage];

          if (currentPost.isVideo) {
            await _controller.waitForVideoCompletion(currentPost.id);
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageViewController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostDetailsPageViewScope(
      controller: _pageViewController,
      child: PostDetails(
        data: PostDetailsData(
          posts: widget.posts,
          controller: _controller,
        ),
        child: CurrentPostScope(
          post: _controller.currentPost,
          child: widget.child,
        ),
      ),
    );
  }
}

class CurrentPostScope<T extends Post> extends StatelessWidget {
  const CurrentPostScope({
    required this.post,
    required this.child,
    super.key,
  });

  final ValueNotifier<T> post;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post,
      builder: (context, post, _) => InheritedPost<T>(
        post: post,
        child: child,
      ),
    );
  }
}
