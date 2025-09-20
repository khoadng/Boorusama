// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../videos/types.dart';
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

  final Map<int, BooruPlayer> _booruPlayers = {};

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
  ) {
    _booruPlayers[id]?.seek(position);

    _seekStreamController.add(
      VideoProgress(
        position,
        _videoProgress.value.duration,
      ),
    );
  }

  bool isPlaying(int id) {
    return _booruPlayers[id]?.isPlaying ?? false;
  }

  Future<void> playVideo(int id) async {
    unawaited(_booruPlayers[id]?.play());
    _isVideoPlaying.value = true;
  }

  Future<void> playCurrentVideo() {
    final post = currentPost.value;

    return playVideo(post.id);
  }

  Future<void> pauseCurrentVideo() {
    final post = currentPost.value;

    return pauseVideo(
      post.id,
    );
  }

  Future<void> pauseVideo(int id) async {
    unawaited(_booruPlayers[id]?.pause());
    _isVideoPlaying.value = false;
  }

  void onBooruVideoPlayerCreated(BooruPlayer player, int id) {
    _booruPlayers[id] = player;
  }

  // ignore: use_setters_to_change_properties
  void onInitializing(bool value) {
    _isVideoInitializing.value = value;
  }

  @override
  void dispose() {
    for (final player in _booruPlayers.values) {
      player.dispose();
    }

    _booruPlayers.clear();

    _videoProgress.dispose();
    _isVideoPlaying.dispose();
    _isVideoInitializing.dispose();
    _seekStreamController.close();

    currentPage.dispose();
    currentPost.dispose();

    super.dispose();
  }
}
