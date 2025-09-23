// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

abstract class BooruPlayer {
  Future<void> initialize(
    String url, {
    VideoConfig? config,
  });

  /// Fast URL switching without full player recreation when possible
  Future<void> switchUrl(
    String url, {
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

typedef PositionCallback =
    void Function(double current, double total, String url);

typedef VideoPlayerCreatedCallback = void Function(BooruPlayer player);
