// Flutter imports:
import 'package:flutter/foundation.dart';

enum VideoPlayerEngine {
  auto,
  videoPlayerPlugin,
  mdk,
  mpv,
  webview;

  factory VideoPlayerEngine.parse(dynamic value) => switch (value) {
    'auto' || '0' || 0 => auto,
    'video_player_plugin' || '1' || 1 => videoPlayerPlugin,
    'mdk' || '2' || 2 => mdk,
    'mpv' || '3' || 3 => mpv,
    'webview' || '4' || 4 => webview,
    _ => defaultValue,
  };

  static const VideoPlayerEngine defaultValue = auto;

  static List<VideoPlayerEngine> getSupportedEnginesForPlatform(
    TargetPlatform platform,
  ) => switch (platform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => values,
    TargetPlatform.linux || TargetPlatform.windows => [
      auto,
      mdk,
      mpv,
    ],
    TargetPlatform.fuchsia => [],
  };

  dynamic toData() => index;
}
