// Package imports:
import 'package:path/path.dart' show extension;

// Project imports:
import '../../../settings/settings.dart';
import 'booru_player.dart';

sealed class VideoPlayerState {
  const VideoPlayerState();
  static VideoPlayerEngine resolveVideoEngine({
    required VideoPlayerEngine? engine,
    required String url,
    bool isAndroid = false,
  }) => switch (engine ?? VideoPlayerEngine.auto) {
    VideoPlayerEngine.auto =>
      extension(url) == '.webm' && isAndroid
          ? VideoPlayerEngine.webview
          : VideoPlayerEngine.videoPlayerPlugin,
    final resolved => resolved,
  };

  static VideoPlayerState fromPlayerState({
    required BooruPlayer? player,
    required String? error,
    required String? thumbnailUrl,
    required bool isBuffering,
    required double? aspectRatio,
  }) => switch ((
    player: player,
    error: error,
    thumbnailUrl: thumbnailUrl,
  )) {
    (player: final player?, error: _, thumbnailUrl: _)
        when !player.isPlatformSupported() =>
      const VideoPlayerUnsupported(),
    (player: final player?, error: _, thumbnailUrl: _) => VideoPlayerReady(
      player,
      thumbnailUrl,
      isBuffering,
      aspectRatio ?? player.aspectRatio,
    ),
    (player: null, error: final error?, thumbnailUrl: _) => VideoPlayerError(
      error,
    ),
    (player: null, error: null, thumbnailUrl: final thumb?) =>
      VideoPlayerLoadingWithThumbnail(
        thumb,
        aspectRatio ?? 16.0 / 9.0,
      ),
    (player: null, error: null, thumbnailUrl: null) =>
      const VideoPlayerLoading(),
  };
}

class VideoPlayerReady extends VideoPlayerState {
  const VideoPlayerReady(
    this.player,
    this.thumbnailUrl,
    this.isBuffering,
    this.aspectRatio,
  );
  final BooruPlayer player;
  final String? thumbnailUrl;
  final bool isBuffering;
  final double aspectRatio;
}

class VideoPlayerUnsupported extends VideoPlayerState {
  const VideoPlayerUnsupported();
}

class VideoPlayerError extends VideoPlayerState {
  const VideoPlayerError(this.error);
  final String error;
}

class VideoPlayerLoadingWithThumbnail extends VideoPlayerState {
  const VideoPlayerLoadingWithThumbnail(
    this.thumbnailUrl,
    this.aspectRatio,
  );
  final String thumbnailUrl;
  final double aspectRatio;
}

class VideoPlayerLoading extends VideoPlayerState {
  const VideoPlayerLoading();
}
