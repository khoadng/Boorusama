// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../lock/types.dart';
import '../engines/media_kit_booru_player.dart';
import '../engines/video_player_booru_player.dart';
import '../engines/webview_booru_player.dart';
import '../types/booru_player.dart';
import '../types/video_engine.dart';

BooruPlayer createBooruPlayer({
  required VideoPlayerEngine engine,
  String? userAgent,
}) => switch (engine) {
  VideoPlayerEngine.webview => WebViewBooruPlayer(
    wakelock: Wakelock(),
    //FIXME: pass user agent for other impl as well?
    userAgent: userAgent,
  ),
  VideoPlayerEngine.mpv => MediaKitBooruPlayer(
    wakelock: Wakelock(),
  ),
  VideoPlayerEngine.auto ||
  VideoPlayerEngine.videoPlayerPlugin ||
  VideoPlayerEngine.mdk => VideoPlayerBooruPlayer(
    wakelock: Wakelock(),
    videoPlayerEngine: engine,
  ),
};

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
    VideoPlayerEngine.mpv => 'MPV',
    VideoPlayerEngine.webview => 'WebView',
  };
}
