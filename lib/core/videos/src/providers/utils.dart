// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../settings/settings.dart';

class VideoEngineUtils {
  static String getUnderlyingEngineName(
    VideoPlayerEngine engine, {
    required TargetPlatform platform,
    required BuildContext context,
  }) => switch (engine) {
    VideoPlayerEngine.videoPlayerPlugin => switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 'AVPlayer',
      TargetPlatform.android => 'ExoPlayer',
      TargetPlatform.windows || TargetPlatform.linux => 'Unsupported',
      _ => context.t.settings.image_viewer.video.engine.kDefault,
    },
    VideoPlayerEngine.auto => context.t.settings.image_viewer.video.engine.auto,
    VideoPlayerEngine.mdk => 'MDK',
    VideoPlayerEngine.webview => 'WebView',
  };
}
