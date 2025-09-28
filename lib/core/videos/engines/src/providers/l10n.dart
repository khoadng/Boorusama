// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../types/video_engine.dart';

extension VideoPlayerEngineTranslated on VideoPlayerEngine {
  String localize(BuildContext context) => switch (this) {
    VideoPlayerEngine.auto => 'Default',
    VideoPlayerEngine.videoPlayerPlugin => 'video_player',
    VideoPlayerEngine.mdk => 'mdk',
    VideoPlayerEngine.mpv => 'mpv',
    VideoPlayerEngine.webview => 'webview',
  };
}
