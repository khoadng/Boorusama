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

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  bool _isDisposed = false;
  Duration _lastPosition = Duration.zero;

  @override
  Future<void> initialize(String url, {Map<String, String>? headers}) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    // Initialize FVP with current engine settings
    FvpManager().ensureInitialized(videoPlayerEngine);

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: headers ?? {},
    );

    _controller!.addListener(_onVideoPlayerChanged);

    await _controller!.initialize();

    _startPositionTimer();
    _durationController.add(_controller!.value.duration);
  }

  void _onVideoPlayerChanged() {
    if (_isDisposed || _controller == null) return;

    final value = _controller!.value;

    // Update playing state
    _playingController.add(value.isPlaying);

    // Update buffering state
    _bufferingController.add(value.isBuffering);

    // Update position if it changed significantly
    if ((value.position - _lastPosition).abs() >
        const Duration(milliseconds: 100)) {
      _lastPosition = value.position;
      _positionController.add(value.position);
    }

    // Update duration if it changed
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
    _controller?.removeListener(_onVideoPlayerChanged);
    _controller?.dispose();

    _positionController.close();
    _playingController.close();
    _bufferingController.close();
    _durationController.close();
  }
}
