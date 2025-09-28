// Flutter imports:
import 'package:flutter/foundation.dart';

enum VideoPlayerEngine {
  auto,
  videoPlayerPlugin,
  mdk,
  mpv,
  webview;

  static List<VideoPlayerEngine> getSupportedEnginesForPlatform(
    TargetPlatform platform,
  ) => switch (platform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => VideoPlayerEngine.values,
    TargetPlatform.linux || TargetPlatform.windows => [
      VideoPlayerEngine.auto,
      VideoPlayerEngine.mdk,
      VideoPlayerEngine.mpv,
    ],
    TargetPlatform.fuchsia => [],
  };
}
