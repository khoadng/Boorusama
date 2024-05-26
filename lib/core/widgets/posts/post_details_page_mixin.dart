// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/widgets/embedded_webview_webm.dart';

mixin PostDetailsPageMixin<T extends StatefulWidget, E extends Post>
    on State<T> {
  final _videoProgress = ValueNotifier(VideoProgress.zero);

  //TODO: should have an abstraction for this crap, but I'm too lazy to do it since there are only 2 types of video anyway
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, WebmVideoController> _webmVideoControllers = {};

  List<E> get posts;
  DetailsPageController get controller;
  Function(int page) get onPageChanged;
  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;
  int get initialPage;
  late var _page = initialPage;

  void onSwiped(int page) {
    _videoProgress.value = VideoProgress.zero;
    if (posts[page].isVideo) {
      controller.disableSwipeDownToDismiss();
    } else {
      controller.enableSwipeDownToDismiss();
    }

    // Pause previous video
    if (posts[page].videoUrl.endsWith('.webm')) {
      _webmVideoControllers[_page]?.pause();
    } else {
      _videoControllers[_page]?.pause();
    }

    onPageChanged.call(page);
    _page = page;
  }

  void onCurrentPositionChanged(double current, double total, String url) {
    // check if the current video is the same as the one being played
    if (posts[_page].videoUrl != url) return;

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
    controller.setEnablePageSwipe(!zoom);
  }

  void onImageTap() {
    if (controller.slideshow.value) {
      controller.stopSlideshow();
    }
    controller.toggleOverlay();
  }
}

class FlexibleLayoutSwitcher extends StatelessWidget {
  const FlexibleLayoutSwitcher({
    super.key,
    required this.desktop,
    required this.mobile,
  });

  final Widget Function() desktop;
  final Widget Function() mobile;

  @override
  Widget build(BuildContext context) {
    return kPreferredLayout.isMobile
        ? OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait ? mobile() : desktop(),
          )
        : desktop();
  }
}

class PostDetailsLayoutSwitcher extends ConsumerStatefulWidget {
  const PostDetailsLayoutSwitcher({
    super.key,
    required this.initialIndex,
    required this.desktop,
    required this.mobile,
    required this.scrollController,
  });

  final int initialIndex;
  final AutoScrollController? scrollController;
  final Widget Function(PostDetailsController controller) desktop;
  final Widget Function(PostDetailsController controller) mobile;

  @override
  ConsumerState<PostDetailsLayoutSwitcher> createState() =>
      _PostDetailsLayoutSwitcherState();
}

class _PostDetailsLayoutSwitcherState
    extends ConsumerState<PostDetailsLayoutSwitcher> {
  late PostDetailsController controller = PostDetailsController(
    scrollController: widget.scrollController,
    initialPage: widget.initialIndex,
    reduceAnimations: ref.read(settingsProvider).reduceAnimations,
  );

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlexibleLayoutSwitcher(
      desktop: () => widget.desktop(controller),
      mobile: () => widget.mobile(controller),
    );
  }
}

class PostDetailsController extends ChangeNotifier {
  PostDetailsController({
    required this.scrollController,
    required int initialPage,
    required this.reduceAnimations,
  }) : currentPage = ValueNotifier(initialPage);
  final AutoScrollController? scrollController;
  final bool reduceAnimations;

  late ValueNotifier<int> currentPage;

  void setPage(int page) {
    currentPage.value = page;
  }

  void onExit(int page) {
    // https://github.com/quire-io/scroll-to-index/issues/44
    // skip scrolling if reduceAnimations is enabled due to a limitation in the package
    if (reduceAnimations) return;

    scrollController?.scrollToIndex(page);
  }
}
