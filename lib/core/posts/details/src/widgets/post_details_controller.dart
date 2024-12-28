// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import '../../../../../../core/widgets/widgets.dart';
import '../../../../foundation/platform.dart';
import '../../../../videos/video_progress.dart';
import '../../../post/post.dart';

class PostDetailsController<T extends Post> extends ChangeNotifier {
  PostDetailsController({
    required this.scrollController,
    required int initialPage,
    required this.posts,
    required this.reduceAnimations,
  })  : currentPage = ValueNotifier(initialPage),
        _initialPage = initialPage,
        currentPost = ValueNotifier(posts[initialPage]);
  final AutoScrollController? scrollController;
  final bool reduceAnimations;
  final List<T> posts;
  final int _initialPage;

  late ValueNotifier<int> currentPage;
  late ValueNotifier<T> currentPost;

  int get initialPage =>
      currentPage.value != _initialPage ? currentPage.value : _initialPage;

  void setPage(
    int page, {
    required bool useDefaultEngine,
  }) {
    currentPage.value = page;
    _videoProgress.value = VideoProgress.zero;
    _isVideoPlaying.value = false;

    final post = posts.getOrNull(page);

    if (post != null) {
      currentPost.value = post;
      if (page == initialPage.toDouble()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          playVideo(
            post.id,
            post.isWebm,
            useDefaultEngine,
          );
        });
        return;
      }
    }
  }

  void onExit() {
    // https://github.com/quire-io/scroll-to-index/issues/44
    // skip scrolling if reduceAnimations is enabled due to a limitation in the package
    if (reduceAnimations) return;

    final page = currentPage.value;

    scrollController?.scrollToIndex(page);
  }

  final _videoProgress = ValueNotifier(VideoProgress.zero);
  final _isVideoPlaying = ValueNotifier<bool>(false);

  //TODO: should have an abstraction for this crap, but I'm too lazy to do it since there are only 2 types of video anyway
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, WebmVideoController> _webmVideoControllers = {};

  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;
  ValueNotifier<bool> get isVideoPlaying => _isVideoPlaying;

  void onCurrentPositionChanged(double current, double total, String url) {
    // // check if the current video is the same as the one being played
    if (posts[currentPage.value].videoUrl != url) return;

    _videoProgress.value = VideoProgress(
      Duration(milliseconds: (total * 1000).toInt()),
      Duration(milliseconds: (current * 1000).toInt()),
    );
  }

  void onVideoSeekTo(
    Duration position,
    int id,
    bool isWebm,
    bool useDefaultEngine,
  ) {
    // Only Android is using Webview for webm
    if (isWebm && isAndroid() && useDefaultEngine) {
      _webmVideoControllers[id]?.seek(position.inSeconds.toDouble());
    } else {
      _videoControllers[id]?.seekTo(position);
    }
  }

  bool isPlaying(int id, bool isWebm, bool useDefaultEngine) {
    if (isWebm && isAndroid() && useDefaultEngine) {
      return _webmVideoControllers[id]?.isPlaying ?? false;
    } else {
      return _videoControllers[id]?.value.isPlaying ?? false;
    }
  }

  Future<void> playVideo(int id, bool isWebm, bool useDefaultEngine) async {
    if (isWebm && isAndroid() && useDefaultEngine) {
      unawaited(_webmVideoControllers[id]?.play());
    } else {
      unawaited(_videoControllers[id]?.play());
    }

    _isVideoPlaying.value = true;
  }

  Future<void> playCurrentVideo({
    required bool useDefaultEngine,
  }) {
    final post = currentPost.value;

    return playVideo(post.id, post.isWebm, useDefaultEngine);
  }

  Future<void> pauseCurrentVideo({
    required bool useDefaultEngine,
  }) {
    final post = currentPost.value;

    return pauseVideo(
      post.id,
      post.isWebm,
      useDefaultEngine,
    );
  }

  Future<void> pauseVideo(int id, bool isWebm, bool useDefaultEngine) async {
    if (isWebm && isAndroid() && useDefaultEngine) {
      unawaited(_webmVideoControllers[id]?.pause());
    } else {
      unawaited(_videoControllers[id]?.pause());
    }

    _isVideoPlaying.value = false;
  }

  void onWebmVideoPlayerCreated(WebmVideoController controller, int id) {
    _webmVideoControllers[id] = controller;
  }

  void onVideoPlayerCreated(VideoPlayerController controller, int id) {
    _videoControllers[id] = controller;
  }
}
