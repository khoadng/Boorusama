// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/ui/booru_video_progress_bar.dart';
import 'package:boorusama/core/ui/details_page.dart';

mixin PostDetailsPageMixin<T extends StatefulWidget, E extends Post>
    on State<T> {
  final _videoProgress = ValueNotifier(VideoProgress.zero);

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
    onPageChanged.call(page);
    _page = page;
  }

  void onCurrentPositionChanged(double current, double total, String url) {
    // check if the current video is the same as the one being played
    if (posts[_page].sampleImageUrl != url) return;

    _videoProgress.value = VideoProgress(
        Duration(milliseconds: (total * 1000).toInt()),
        Duration(milliseconds: (current * 1000).toInt()));
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
