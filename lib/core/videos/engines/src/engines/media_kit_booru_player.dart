// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// Project imports:
import '../../../lock/types.dart';
import '../types/booru_player.dart';
import '../types/video_source.dart';
import 'media_kit_manager.dart';

class MediaKitBooruPlayer implements BooruPlayer {
  MediaKitBooruPlayer({
    required this.wakelock,
    this.enableHardwareAcceleration = true,
  });

  final bool enableHardwareAcceleration;
  final Wakelock wakelock;

  late final Player _player;
  late final VideoController _videoController;

  final _positionController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _bufferingController = StreamController<bool>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<bool>? _bufferingSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  Timer? _bufferingDelayTimer;

  var _isDisposed = false;
  var _isInitialized = false;
  var _hasPlayedOnce = false;

  @override
  bool isPlatformSupported() => true;

  void _setupStreamListeners() {
    _positionSubscription = _player.stream.position.listen((position) {
      if (!_isDisposed) {
        _positionController.add(position);
      }
    });

    _playingSubscription = _player.stream.playing.listen((playing) {
      if (!_isDisposed) {
        _playingController.add(playing);
        if (playing) {
          wakelock.enable();
          if (!_hasPlayedOnce) {
            _hasPlayedOnce = true;
          }
        } else {
          wakelock.disable();
        }
      }
    });

    _bufferingSubscription = _player.stream.buffering.listen((buffering) {
      _handleSmartBuffering(buffering);
    });

    _durationSubscription = _player.stream.duration.listen((duration) {
      if (!_isDisposed) {
        _durationController.add(duration);
      }
    });
  }

  Future<void> _openMedia(VideoSource source, VideoConfig? config) async {
    final media = Media(
      source.url,
      httpHeaders: config?.headers ?? {},
    );

    await _player.open(media, play: false);
    await _player.setPlaylistMode(PlaylistMode.single);

    if (_player.state.duration != Duration.zero) {
      _durationController.add(_player.state.duration);
    }
  }

  @override
  Future<void> initialize(
    VideoSource source, {
    VideoConfig? config,
  }) async {
    if (_isDisposed) throw StateError('Player has been disposed');

    MediaKitManager().ensureInitialized();

    _player = Player();
    _videoController = VideoController(
      _player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: enableHardwareAcceleration,
      ),
    );

    _setupStreamListeners();
    await _openMedia(source, config);

    _isInitialized = true;
  }

  @override
  Future<void> switchUrl(
    VideoSource source, {
    VideoConfig? config,
  }) async {
    if (_isDisposed) throw StateError('Player has been disposed');
    if (!_isInitialized) {
      return initialize(source, config: config);
    }

    _hasPlayedOnce = false;
    await _openMedia(source, config);
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
          if (!_isDisposed && _player.state.buffering) {
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
    if (_isDisposed || !_isInitialized) return;
    await _player.play();
  }

  @override
  Future<void> pause() async {
    if (_isDisposed || !_isInitialized) return;
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed || !_isInitialized) return;
    await _player.seek(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_isDisposed || !_isInitialized) return;
    // media_kit uses 0.0 to 100.0 range, but BooruPlayer interface expects 0.0 to 1.0
    await _player.setVolume((volume.clamp(0.0, 1.0) * 100.0).clamp(0.0, 100.0));
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    if (_isDisposed || !_isInitialized) return;
    await _player.setRate(speed);
  }

  @override
  Future<void> setLooping(bool loop) async {
    if (_isDisposed || !_isInitialized) return;
    await _player.setPlaylistMode(
      loop ? PlaylistMode.single : PlaylistMode.none,
    );
  }

  @override
  bool get isPlaying =>
      _isDisposed || !_isInitialized ? false : _player.state.playing;

  @override
  Duration get position =>
      _isDisposed || !_isInitialized ? Duration.zero : _player.state.position;

  @override
  Duration get duration =>
      _isDisposed || !_isInitialized ? Duration.zero : _player.state.duration;

  @override
  double get aspectRatio {
    if (_isDisposed || !_isInitialized) return 16.0 / 9.0;

    final width = _player.state.width;
    final height = _player.state.height;

    if (width != null && height != null && width > 0 && height > 0) {
      return width / height;
    }

    return 16.0 / 9.0;
  }

  @override
  int? get width => _isDisposed || !_isInitialized ? null : _player.state.width;

  @override
  int? get height =>
      _isDisposed || !_isInitialized ? null : _player.state.height;

  @override
  bool get isBuffering =>
      _isDisposed || !_isInitialized ? false : _player.state.buffering;

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
    if (_isDisposed || !_isInitialized) {
      return const SizedBox.shrink();
    }

    return Video(
      controller: _videoController,
      controls: NoVideoControls,
      fill: Colors.transparent,
      wakelock: false, // We handle wakelock ourselves
    );
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    wakelock.disable();

    _bufferingDelayTimer?.cancel();
    _positionSubscription?.cancel();
    _playingSubscription?.cancel();
    _bufferingSubscription?.cancel();
    _durationSubscription?.cancel();

    _positionController.close();
    _playingController.close();
    _bufferingController.close();
    _durationController.close();

    _player.dispose();
  }
}
