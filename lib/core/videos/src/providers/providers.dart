// ignore_for_file: use_setters_to_change_properties

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../http/providers.dart';
import '../../../settings/providers.dart';
import '../../../settings/settings.dart';
import '../types/booru_player.dart';
import 'media_kit_booru_player.dart';
import 'video_player_booru_player.dart';
import 'wakelock.dart';
import 'webview_booru_player.dart';

class GlobalSoundNotifier extends Notifier<bool> {
  @override
  bool build() {
    final isMuteByDefault = ref.watch(
      settingsProvider.select((s) => s.viewer.muteAudioByDefault),
    );

    return !isMuteByDefault;
  }

  void toggle() {
    state = !state;
  }

  void setState(bool value) {
    state = value;
  }
}

final globalSoundStateProvider = NotifierProvider<GlobalSoundNotifier, bool>(
  GlobalSoundNotifier.new,
);

class PlaybackSpeedNotifier extends AutoDisposeFamilyNotifier<double, String> {
  @override
  double build(String url) => 1;

  void setSpeed(double value) {
    state = value;
  }
}

final playbackSpeedProvider =
    AutoDisposeNotifierProviderFamily<PlaybackSpeedNotifier, double, String>(
      PlaybackSpeedNotifier.new,
    );

final videoCacheManagerProvider = Provider<VideoCacheManager?>(
  (ref) {
    final enable = ref.watch(
      settingsProvider.select((s) => s.enableVideoCache),
    );

    if (!enable) return null;

    final videoCacheSize = ref.watch(
      settingsProvider.select((s) => s.videoCacheMaxSize),
    );

    if (videoCacheSize.isZero) return null;

    final manager = VideoCacheManager(
      maxTotalCacheSize: videoCacheSize.bytes,
      fileDownloader: FileDownloader(),
      dio: ref.watch(genericDioProvider),
    );

    ref.onDispose(() {
      manager.dispose();
    });

    return manager;
  },
);

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
