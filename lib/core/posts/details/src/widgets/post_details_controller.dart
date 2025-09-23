// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../../foundation/platform.dart';
import '../../../../settings/settings.dart';
import '../../../../videos/providers.dart';
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
    required this.headers,
    required this.videoPlayerEngine,
    required this.userAgent,
    required this.logger,
  }) : currentPage = ValueNotifier(initialPage),
       _initialPage = initialPage,
       currentPost = ValueNotifier(posts[initialPage]);
  final AutoScrollController? scrollController;
  final bool reduceAnimations;
  final List<T> posts;
  final int _initialPage;
  final String? initialThumbnailUrl;
  final String? dislclaimer;
  final Map<String, String>? headers;
  final VideoPlayerEngine? videoPlayerEngine;
  final String? userAgent;
  final Logger? logger;

  late ValueNotifier<int> currentPage;
  late ValueNotifier<T> currentPost;

  final StreamController<VideoProgress> _seekStreamController =
      StreamController<VideoProgress>.broadcast();

  Stream<VideoProgress> get seekStream => _seekStreamController.stream;

  int get initialPage =>
      currentPage.value != _initialPage ? currentPage.value : _initialPage;

  void setPage(int page) {
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

      // Pause all other players first
      for (final playerId in _booruPlayers.keys) {
        if (playerId != post.id) {
          unawaited(_booruPlayers[playerId]?.pause());
        }
      }

      // Handle video posts
      if (post.isVideo) {
        if (!_booruPlayers.containsKey(post.id)) {
          // Initialize player without autoplay - controller will manage play state
          _initializePlayerForPost(post, autoplay: false);
        } else {
          // Player exists, explicitly play it
          WidgetsBinding.instance.addPostFrameCallback((_) {
            playVideo(post.id);
          });
        }
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
  final Map<int, String?> _playerErrors = {};
  final Map<int, bool> _playerInitializing = {};
  final Map<int, bool> _playerBuffering = {};
  final Map<int, StreamSubscription<Duration>?> _positionSubscriptions = {};
  final Map<int, StreamSubscription<bool>?> _bufferingSubscriptions = {};

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

  void _log(
    void Function(String tag, String message)? logMethod,
    String message,
  ) => logMethod?.call('PostDetailsController', message);

  VideoPlayerEngine get _resolvedEngine => VideoPlayerState.resolveVideoEngine(
    engine: videoPlayerEngine,
    url: currentPost.value.videoUrl,
    isAndroid: isAndroid(),
  );

  Future<BooruPlayer?> _createPlayerForPost(T post) async {
    if (!post.isVideo) return null;

    try {
      _log(
        logger?.debug,
        'Creating $_resolvedEngine player for post ${post.id}',
      );

      final player = createBooruPlayer(
        engine: _resolvedEngine,
        userAgent: userAgent,
      );

      if (!player.isPlatformSupported()) {
        _log(
          logger?.warn,
          'Player engine $_resolvedEngine not supported on this platform',
        );
        return null;
      }

      // Set up position stream listener
      _positionSubscriptions[post.id] = player.positionStream.listen((
        position,
      ) {
        final current = position.inMilliseconds / 1000.0;
        final total = player.duration.inMilliseconds / 1000.0;
        onCurrentPositionChanged(current, total, post.videoUrl);
      });

      // Set up buffering stream listener
      _bufferingSubscriptions[post.id] = player.bufferingStream.listen((
        buffering,
      ) {
        _playerBuffering[post.id] = buffering;
        notifyListeners();
      });

      _log(
        logger?.debug,
        'Successfully created player for post ${post.id}',
      );
      return player;
    } catch (error) {
      _log(
        logger?.error,
        'Failed to create player for post ${post.id}: $error',
      );
      _playerErrors[post.id] = error.toString();
      return null;
    }
  }

  Future<void> _initializePlayerForPost(T post, {bool autoplay = false}) async {
    if (!post.isVideo || _booruPlayers.containsKey(post.id)) return;

    _playerInitializing[post.id] = true;
    _playerErrors.remove(post.id);
    notifyListeners();

    try {
      final player = await _createPlayerForPost(post);
      if (player == null) return;

      _log(
        logger?.debug,
        'Initializing player for post ${post.id} with autoplay: $autoplay',
      );

      await player.initialize(
        post.videoUrl,
        headers: headers,
        autoplay: autoplay,
      );

      await player.setLooping(true);

      _booruPlayers[post.id] = player;
      _log(
        logger?.verbose,
        'Player successfully initialized for post ${post.id}',
      );

      // If this is the current post, start playing
      if (post.id == currentPost.value.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          playVideo(post.id);
        });
      }
    } catch (error) {
      _log(
        logger?.error,
        'Failed to initialize player for post ${post.id}: $error',
      );
      _playerErrors[post.id] = error.toString();
    } finally {
      _playerInitializing[post.id] = false;
      notifyListeners();
    }
  }

  BooruPlayer? getPlayerForPost(int postId) {
    return _booruPlayers[postId];
  }

  String? getPlayerError(int postId) {
    return _playerErrors[postId];
  }

  bool isPlayerInitializing(int postId) {
    return _playerInitializing[postId] ?? false;
  }

  bool isPlayerBuffering(int postId) {
    return _playerBuffering[postId] ?? false;
  }

  Future<void> updatePlayerSound(bool sound) async {
    final currentPostId = currentPost.value.id;
    final player = _booruPlayers[currentPostId];
    if (player == null) return;

    final volume = sound ? 1.0 : 0.0;

    _log(
      logger?.debug,
      'Updating player sound for post $currentPostId - Volume: $volume',
    );

    await player.setVolume(volume);
  }

  Future<void> updatePlayerSpeed(double speed) async {
    final currentPostId = currentPost.value.id;
    final player = _booruPlayers[currentPostId];
    if (player == null) return;

    _log(
      logger?.debug,
      'Updating player speed for post $currentPostId - Speed: $speed',
    );

    await player.setPlaybackSpeed(speed);
  }

  // ignore: use_setters_to_change_properties
  void onInitializing(bool value) {
    _isVideoInitializing.value = value;
  }

  void _disposePlayer(int postId) {
    _log(
      logger?.debug,
      'Disposing player for post $postId',
    );

    _positionSubscriptions[postId]?.cancel();
    _positionSubscriptions.remove(postId);

    _bufferingSubscriptions[postId]?.cancel();
    _bufferingSubscriptions.remove(postId);

    _booruPlayers[postId]?.dispose();
    _booruPlayers.remove(postId);

    _playerErrors.remove(postId);
    _playerInitializing.remove(postId);
    _playerBuffering.remove(postId);
  }

  @override
  void dispose() {
    _log(
      logger?.debug,
      'Disposing PostDetailsController',
    );

    for (final postId in _booruPlayers.keys.toList()) {
      _disposePlayer(postId);
    }

    _videoProgress.dispose();
    _isVideoPlaying.dispose();
    _isVideoInitializing.dispose();
    _seekStreamController.close();

    currentPage.dispose();
    currentPost.dispose();

    super.dispose();
  }
}
