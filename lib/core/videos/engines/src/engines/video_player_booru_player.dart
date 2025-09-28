// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import '../../../lock/types.dart';
import '../types/booru_player.dart';
import '../types/video_engine.dart';
import '../types/video_source.dart';
import 'fvp_manager.dart';

class VideoPlayerBooruPlayer implements BooruPlayer {
  VideoPlayerBooruPlayer({
    required this.wakelock,
    this.videoPlayerEngine = VideoPlayerEngine.auto,
  });

  final VideoPlayerEngine videoPlayerEngine;
  final Wakelock wakelock;

  VideoPlayerController? _controller;
  Timer? _positionTimer;
  Timer? _bufferingDelayTimer;

  final _positionController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _bufferingController = StreamController<bool>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  var _isDisposed = false;
  var _hasPlayedOnce = false;

  bool get _isInvalid => _isDisposed || _controller == null;

  void _withValidController(
    void Function(VideoPlayerController controller) operation,
  ) {
    if (_isInvalid) return;
    operation(_controller!);
  }

  Future<void> _withValidControllerAsync(
    Future<void> Function(VideoPlayerController controller) operation,
  ) async {
    if (_isInvalid) return;
    await operation(_controller!);
  }

  T _withValidControllerOr<T>(
    T Function(VideoPlayerController controller) operation,
    T defaultValue,
  ) {
    if (_isInvalid) return defaultValue;
    return operation(_controller!);
  }

  @override
  bool isPlatformSupported() => true;

  VideoPlayerController _createController(
    VideoSource source,
    VideoConfig? config,
  ) {
    return VideoPlayerController.networkUrl(
      Uri.parse(source.url),
      httpHeaders: config?.headers ?? {},
    )..addListener(_onVideoPlayerChanged);
  }

  Future<void> _setupController(VideoPlayerController controller) async {
    await controller.initialize();
    _startPositionTimer();
    _durationController.add(controller.value.duration);
  }

  @override
  Future<void> initialize(
    VideoSource source, {
    VideoConfig? config,
  }) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    FvpManager().ensureInitialized(videoPlayerEngine);

    final controller = _createController(source, config);
    _controller = controller;

    await _setupController(controller);
  }

  @override
  Future<void> switchUrl(
    VideoSource source, {
    VideoConfig? config,
  }) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    final oldController = _controller;
    _hasPlayedOnce = false;

    final controller = _createController(source, config);
    await _setupController(controller);

    _controller = controller;

    // Dispose old controller in background
    if (oldController != null) {
      oldController.removeListener(_onVideoPlayerChanged);
      unawaited((() => oldController.dispose())());
    }
  }

  void _onVideoPlayerChanged() => _withValidController((controller) {
    final value = controller.value;

    _playingController.add(value.isPlaying);
    if (value.isPlaying) {
      wakelock.enable();
      if (!_hasPlayedOnce) {
        _hasPlayedOnce = true;
      }
    } else {
      wakelock.disable();
    }

    _handleSmartBuffering(value.isBuffering);

    _positionController.add(value.position);

    if (value.duration != Duration.zero) {
      _durationController.add(value.duration);
    }
  });

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isInvalid) {
        timer.cancel();
        return;
      }

      _withValidController(
        (controller) {
          if (controller.value.isPlaying) {
            _positionController.add(controller.value.position);
          }
        },
      );
    });
  }

  void _handleSmartBuffering(bool buffering) {
    if (_isDisposed) return;

    if (buffering) {
      // If we haven't played once yet, always show buffering (initial load)
      if (!_hasPlayedOnce) {
        _bufferingController.add(true);
      } else {
        // For subsequent buffering, check if it's a genuine network issue
        // by adding a small delay to filter out loop-related buffering
        _bufferingDelayTimer?.cancel();
        _bufferingDelayTimer = Timer(const Duration(milliseconds: 200), () {
          _withValidController((controller) {
            if (controller.value.isBuffering) {
              _bufferingController.add(true);
            }
          });
        });
      }
    } else {
      // Not buffering, cancel delay timer and hide indicator
      _bufferingDelayTimer?.cancel();
      _bufferingController.add(false);
    }
  }

  @override
  Future<void> play() =>
      _withValidControllerAsync((controller) => controller.play());

  @override
  Future<void> pause() =>
      _withValidControllerAsync((controller) => controller.pause());

  @override
  Future<void> seek(Duration position) => _withValidControllerAsync(
    (controller) => controller.seekTo(position),
  );

  @override
  Future<void> setVolume(double volume) => _withValidControllerAsync(
    (controller) => controller.setVolume(volume.clamp(0.0, 1.0)),
  );

  @override
  Future<void> setPlaybackSpeed(double speed) => _withValidControllerAsync(
    (controller) => controller.setPlaybackSpeed(speed),
  );

  @override
  Future<void> setLooping(bool loop) => _withValidControllerAsync(
    (controller) => controller.setLooping(loop),
  );

  @override
  bool get isPlaying =>
      _withValidControllerOr((controller) => controller.value.isPlaying, false);

  @override
  Duration get position => _withValidControllerOr(
    (controller) => controller.value.position,
    Duration.zero,
  );

  @override
  Duration get duration => _withValidControllerOr(
    (controller) => controller.value.duration,
    Duration.zero,
  );

  @override
  double get aspectRatio => _withValidControllerOr(
    (controller) => controller.value.aspectRatio,
    16.0 / 9.0,
  );

  @override
  int? get width => _withValidControllerOr(
    (controller) => controller.value.size.width.toInt(),
    null,
  );

  @override
  int? get height => _withValidControllerOr(
    (controller) => controller.value.size.height.toInt(),
    null,
  );

  @override
  bool get isBuffering => _withValidControllerOr(
    (controller) => controller.value.isBuffering,
    false,
  );

  @override
  bool get hasPlayedOnce => _hasPlayedOnce;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<bool> get bufferingStream => _bufferingController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Widget buildPlayerWidget(BuildContext context) {
    return _withValidControllerOr((controller) {
      if (!controller.value.isInitialized) {
        return const SizedBox.shrink();
      }
      return VideoPlayer(controller);
    }, const SizedBox.shrink());
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    wakelock.disable();

    _positionTimer?.cancel();
    _bufferingDelayTimer?.cancel();
    _controller?.removeListener(_onVideoPlayerChanged);
    _controller?.dispose();

    _positionController.close();
    _playingController.close();
    _bufferingController.close();
    _durationController.close();
  }
}
