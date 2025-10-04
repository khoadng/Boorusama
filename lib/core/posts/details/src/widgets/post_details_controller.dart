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

  int? currentSettledPage;
  late ValueNotifier<int> currentPage;
  late ValueNotifier<T> currentPost;
  final VideoPlaybackManager _playback;

  int get initialPage =>
      currentPage.value != _initialPage ? currentPage.value : _initialPage;

  // ignore: use_setters_to_change_properties
  void setPage(int page) {
    currentPage.value = page;
  }

  void onPageSettled(int page) {
    if (page == currentSettledPage) return;

    currentSettledPage = page;

    final post = posts.getOrNull(page);

    if (post != null) {
      currentPost.value = post;
      _playback.resetProgress();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        playVideo(post.id);
      });
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

  void onCurrentPositionChanged(double current, double total, String id) {
    if (posts.getOrNull(currentSettledPage ?? -1)?.id case final currentId?
        when currentId.toString() == id) {
      _playback.updateProgress(current, total, currentId);
    }
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

  void onBooruVideoPlayerDisposed(int id) {
    _playback.unregisterPlayer(id);
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
