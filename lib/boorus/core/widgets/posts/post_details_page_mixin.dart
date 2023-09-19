// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
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
    if (controller.slideShow.value.$1) {
      controller.stopSlideShow();
    }
    controller.toggleOverlay();
  }
}
