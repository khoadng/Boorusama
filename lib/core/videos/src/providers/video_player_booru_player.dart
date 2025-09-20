// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import '../../../settings/settings.dart';
import '../types/booru_player.dart';
import 'fvp_manager.dart';

class VideoPlayerBooruPlayer implements BooruPlayer {
  VideoPlayerBooruPlayer({
    this.videoPlayerEngine = VideoPlayerEngine.auto,
  });

  final VideoPlayerEngine videoPlayerEngine;

  VideoPlayerController? _controller;
  Timer? _positionTimer;
  Timer? _bufferingDelayTimer;

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  bool _isDisposed = false;
  bool _hasPlayedOnce = false;
  Duration _lastPosition = Duration.zero;

  @override
  Future<void> initialize(
    String url, {
    Map<String, String>? headers,
    bool autoplay = false,
  }) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    // Initialize FVP with current engine settings
    FvpManager().ensureInitialized(videoPlayerEngine);

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: headers ?? {},
    );
    _controller = controller;

    controller.addListener(_onVideoPlayerChanged);

    await controller.initialize();

    _startPositionTimer();
    _durationController.add(controller.value.duration);

    if (autoplay) {
      await controller.play();
    }
  }

  void _onVideoPlayerChanged() {
    if (_isDisposed || _controller == null) return;

    final value = _controller!.value;

    _playingController.add(value.isPlaying);
    if (value.isPlaying && !_hasPlayedOnce) {
      _hasPlayedOnce = true;
    }

    _handleSmartBuffering(value.isBuffering);

    if ((value.position - _lastPosition).abs() >
        const Duration(milliseconds: 100)) {
      _lastPosition = value.position;
      _positionController.add(value.position);
    }

    if (value.duration != Duration.zero) {
      _durationController.add(value.duration);
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (_isDisposed || _controller == null) {
        timer.cancel();
        return;
      }

      if (_controller!.value.isPlaying) {
        final position = _controller!.value.position;
        if ((position - _lastPosition).abs() >
            const Duration(milliseconds: 100)) {
          _lastPosition = position;
          _positionController.add(position);
        }
      }
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
          if (!_isDisposed &&
              _controller != null &&
              _controller!.value.isBuffering) {
            _bufferingController.add(true);
          }
        });
      }
    } else {
      // Not buffering, cancel delay timer and hide indicator
      _bufferingDelayTimer?.cancel();
      _bufferingController.add(false);
    }
  }

  @override
  Future<void> play() async {
    if (_isDisposed || _controller == null) return;
    await _controller!.play();
  }

  @override
  Future<void> pause() async {
    if (_isDisposed || _controller == null) return;
    await _controller!.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed || _controller == null) return;
    await _controller!.seekTo(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_isDisposed || _controller == null) return;
    // video_player uses 0.0 to 1.0 range
    await _controller!.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    if (_isDisposed || _controller == null) return;
    await _controller!.setPlaybackSpeed(speed);
  }

  @override
  Future<void> setLooping(bool loop) async {
    if (_isDisposed || _controller == null) return;
    await _controller!.setLooping(loop);
  }

  @override
  bool get isPlaying =>
      _isDisposed || _controller == null ? false : _controller!.value.isPlaying;

  @override
  Duration get position => _isDisposed || _controller == null
      ? Duration.zero
      : _controller!.value.position;

  @override
  Duration get duration => _isDisposed || _controller == null
      ? Duration.zero
      : _controller!.value.duration;

  @override
  double get aspectRatio => _isDisposed || _controller == null
      ? 16.0 / 9.0
      : _controller!.value.aspectRatio;

  @override
  int? get width => _isDisposed || _controller == null
      ? null
      : _controller!.value.size.width.toInt();

  @override
  int? get height => _isDisposed || _controller == null
      ? null
      : _controller!.value.size.height.toInt();

  @override
  bool get isBuffering => _isDisposed || _controller == null
      ? false
      : _controller!.value.isBuffering;

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
    if (_isDisposed ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return VideoPlayer(_controller!);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

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
