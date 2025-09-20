// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

abstract class BooruPlayer {
  Future<void> initialize(
    String url, {
    Map<String, String>? headers,
    bool autoplay = false,
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
  Widget buildPlayerWidget(BuildContext context);
}

typedef PositionCallback =
    void Function(double current, double total, String url);

typedef VideoPlayerCreatedCallback = void Function(BooruPlayer player);
