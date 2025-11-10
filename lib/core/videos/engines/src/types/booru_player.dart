// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'video_source.dart';

abstract class BooruPlayer {
  Future<void> initialize(
    VideoSource source, {
    VideoConfig? config,
  });

  /// Fast URL switching without full player recreation when possible
  Future<void> switchUrl(
    VideoSource source, {
    VideoConfig? config,
  });

  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> setLooping(bool loop);
  bool get isPlaying;
  Duration get position;
  Duration get duration;
  double get aspectRatio;
  int? get width;
  int? get height;
  bool get isBuffering;
  bool get hasPlayedOnce;
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  Stream<bool> get bufferingStream;
  Stream<Duration> get durationStream;
  void dispose();
  bool isPlatformSupported();
  Widget buildPlayerWidget(BuildContext context);
}

class VideoConfig {
  const VideoConfig({
    this.headers,
    this.autoplay = false,
  });

  final Map<String, String>? headers;
  final bool autoplay;
}

typedef PositionCallback = void Function(double current, double total);

typedef VideoPlayerCreatedCallback = void Function(BooruPlayer player);
typedef VideoPlayerDisposedCallback = void Function();

extension BooruPlayerExtension on BooruPlayer {
  Future<void> waitForCompletion({
    Duration timeout = const Duration(hours: 1),
  }) async {
    if (!isPlaying) return;

    final completer = Completer<void>();
    StreamSubscription<Duration>? positionSub;
    StreamSubscription<bool>? playingSub;

    void complete() {
      if (!completer.isCompleted) {
        positionSub?.cancel();
        playingSub?.cancel();
        completer.complete();
      }
    }

    positionSub = positionStream.listen((position) {
      // Consider video complete if within 500ms of end
      if (duration.inMilliseconds > 0 &&
          position.inMilliseconds >= duration.inMilliseconds - 500) {
        complete();
      }
    });

    playingSub = playingStream.listen((isPlaying) {
      if (!isPlaying) {
        complete();
      }
    });

    try {
      await completer.future.timeout(
        timeout,
        onTimeout: () {
          complete();
        },
      );
    } catch (e) {
      complete();
      rethrow;
    }
  }
}
