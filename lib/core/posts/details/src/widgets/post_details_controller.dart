// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/platform.dart';
import '../../../../videos/video_progress.dart';
import '../../../post/post.dart';

class PostDetailsController<T extends Post> extends ChangeNotifier {
  PostDetailsController({
    required this.scrollController,
    required int initialPage,
    required this.posts,
    required this.initialThumbnailUrl,
    required this.reduceAnimations,
    required this.dislclaimer,
  }) : currentPage = ValueNotifier(initialPage),
       _initialPage = initialPage,
       currentPost = ValueNotifier(posts[initialPage]);
  final AutoScrollController? scrollController;
  final bool reduceAnimations;
  final List<T> posts;
  final int _initialPage;
  final String? initialThumbnailUrl;
  final String? dislclaimer;

  late ValueNotifier<int> currentPage;
  late ValueNotifier<T> currentPost;

  final StreamController<VideoProgress> _seekStreamController =
      StreamController<VideoProgress>.broadcast();

  Stream<VideoProgress> get seekStream => _seekStreamController.stream;

  int get initialPage =>
      currentPage.value != _initialPage ? currentPage.value : _initialPage;

  void setPage(
    int page, {
    required bool useDefaultEngine,
  }) {
    currentPage.value = page;
    _videoProgress.value = VideoProgress.zero;

    final post = posts.getOrNull(page);

    if (post?.isMp4 ?? false) {
      if (_isVideoPlaying.value) {
        _isVideoPlaying.value = false;
      }
    }

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
  final _isVideoInitializing = ValueNotifier<bool>(false);

  //TODO: should have an abstraction for this crap, but I'm too lazy to do it since there are only 2 types of video anyway
  final Map<int, Player> _videoControllers = {};
  final Map<int, WebmVideoController> _webmVideoControllers = {};

  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;
  ValueNotifier<bool> get isVideoPlaying => _isVideoPlaying;
  ValueNotifier<bool> get isVideoInitializing => _isVideoInitializing;

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
      _videoControllers[id]?.seek(position);
    }

    _seekStreamController.add(
      VideoProgress(
        position,
        _videoProgress.value.duration,
      ),
    );
  }

  bool isPlaying(int id, bool isWebm, bool useDefaultEngine) {
    if (isWebm && isAndroid() && useDefaultEngine) {
      return _webmVideoControllers[id]?.isPlaying ?? false;
    } else {
      return _videoControllers[id]?.state.playing ?? false;
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

  void onVideoPlayerCreated(Player controller, int id) {
    _videoControllers[id] = controller;
  }

  // ignore: use_setters_to_change_properties
  void onInitializing(bool value) {
    _isVideoInitializing.value = value;
  }

  @override
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }

    for (final controller in _webmVideoControllers.values) {
      controller.dispose();
    }

    _videoControllers.clear();
    _webmVideoControllers.clear();

    _videoProgress.dispose();
    _isVideoPlaying.dispose();
    _isVideoInitializing.dispose();
    _seekStreamController.close();

    currentPage.dispose();
    currentPost.dispose();

    super.dispose();
  }
}
