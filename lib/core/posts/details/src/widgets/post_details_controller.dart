// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../videos/engines/types.dart';
import '../../../../videos/player/types.dart';
import '../../../post/post.dart';

const kSeekAnimationDuration = Duration(milliseconds: 400);

enum SeekDirection { forward, backward }

class PostDetailsController<T extends Post> extends ChangeNotifier {
  PostDetailsController({
    required this.scrollController,
    required int initialPage,
    required this.posts,
    required this.initialThumbnailUrl,
    required this.reduceAnimations,
    required this.dislclaimer,
    required this.doubleTapSeekDuration,
  }) : currentPage = ValueNotifier(initialPage),
       _initialPage = initialPage,
       currentPost = ValueNotifier(posts[initialPage]),
       _playback = VideoPlaybackManager();
  final AutoScrollController? scrollController;
  final bool reduceAnimations;
  final List<T> posts;
  final int _initialPage;
  final String? initialThumbnailUrl;
  final String? dislclaimer;
  final int doubleTapSeekDuration;

  late ValueNotifier<int> currentPage;
  late ValueNotifier<T> currentPost;
  final VideoPlaybackManager _playback;

  int get initialPage =>
      currentPage.value != _initialPage ? currentPage.value : _initialPage;

  void setPage(int page) {
    currentPage.value = page;
    _playback.resetProgress();

    final post = posts.getOrNull(page);

    if (post?.isMp4 ?? false) {
      if (_playback.isVideoPlaying.value) {
        _playback.isVideoPlaying.value = false;
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

  final _seekDirection = ValueNotifier<SeekDirection?>(null);

  ValueNotifier<VideoProgress> get videoProgress => _playback.videoProgress;
  ValueNotifier<bool> get isVideoPlaying => _playback.isVideoPlaying;
  ValueNotifier<SeekDirection?> get seekDirection => _seekDirection;
  Stream<VideoProgress> get seekStream => _playback.seekStream;

  void onCurrentPositionChanged(double current, double total, String url) {
    // check if the current video is the same as the one being played
    if (posts[currentPage.value].videoUrl != url) return;

    _playback.updateProgress(
      current,
      total,
      url,
      currentPost.value.id,
    );
  }

  void onVideoSeekTo(Duration position, int id) {
    _playback.seekVideo(position, id);
  }

  Future<void> playVideo(int id) async {
    await _playback.playVideo(id);
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
    await _playback.pauseVideo(id);
  }

  Future<void> seekFromDoubleTap(Offset tapPosition, Size viewport) async {
    final post = currentPost.value;
    if (!post.isVideo) return;

    final width = viewport.width;
    final leftBoundary = width * 0.5;

    final direction = switch (tapPosition.dx) {
      final x when x < leftBoundary => SeekDirection.backward,
      final x when x >= leftBoundary => SeekDirection.forward,
      _ => null,
    };

    if (direction != null) {
      final isForward = direction == SeekDirection.forward;
      final seekPosition = _playback.seekVideoByDirection(
        post.id,
        isForward,
        Duration(seconds: post.duration.round()),
        doubleTapSeekDuration,
      );

      if (seekPosition != null) {
        _showSeekAnimation(direction);
      }
    }
  }

  void _showSeekAnimation(SeekDirection direction) {
    _seekDirection.value = direction;

    // Hide the animation after a short delay
    Timer(kSeekAnimationDuration, () {
      if (_seekDirection.value == direction) {
        _seekDirection.value = null;
      }
    });
  }

  void onBooruVideoPlayerCreated(BooruPlayer player, int id) {
    _playback.registerPlayer(player, id);
  }

  @override
  void dispose() {
    _playback.dispose();
    _seekDirection.dispose();

    currentPage.dispose();
    currentPost.dispose();

    super.dispose();
  }
}
