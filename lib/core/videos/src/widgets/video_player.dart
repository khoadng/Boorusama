// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../images/booru_image.dart';
import '../../../widgets/widgets.dart';
import '../types/booru_player.dart';
import '../types/video_player_state.dart';
import 'video_player_error_container.dart';

class BooruVideo extends ConsumerWidget {
  const BooruVideo({
    required this.player,
    required this.aspectRatio,
    super.key,
    this.thumbnailUrl,
    this.onOpenSettings,
    this.heroTag,
    this.error,
    this.isBuffering = false,
  });

  final BooruPlayer? player;
  final double aspectRatio;
  final String? thumbnailUrl;
  final VoidCallback? onOpenSettings;
  final String? heroTag;
  final String? error;
  final bool isBuffering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = VideoPlayerState.fromPlayerState(
      player: player,
      error: error,
      thumbnailUrl: thumbnailUrl,
      isBuffering: isBuffering,
      aspectRatio: aspectRatio,
    );

    return Center(
      child: switch (state) {
        VideoPlayerReady(
          :final player,
          :final thumbnailUrl,
          :final isBuffering,
          :final aspectRatio,
        ) =>
          AspectRatio(
            aspectRatio: aspectRatio,
            child: BooruHero(
              tag: heroTag,
              child: Stack(
                children: [
                  if (thumbnailUrl case final url?)
                    Positioned.fill(
                      child: Consumer(
                        builder: (_, ref, _) => BooruImage(
                          config: ref.watchConfigAuth,
                          borderRadius: BorderRadius.zero,
                          aspectRatio: aspectRatio,
                          imageUrl: url,
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: player.buildPlayerWidget(context),
                  ),
                  if (isBuffering)
                    _BufferingOverlay(
                      thumbnailUrl: thumbnailUrl,
                      aspectRatio: aspectRatio,
                    ),
                ],
              ),
            ),
          ),
        VideoPlayerUnsupported() => VideoPlayerErrorContainer(
          title: context.t.video_player.engine_not_supported,
          subtitle: context.t.video_player.change_video_player_engine_request,
          onOpenSettings: onOpenSettings,
        ),
        VideoPlayerError(:final error) => VideoPlayerErrorContainer(
          title: error,
          subtitle: context.t.video_player.change_video_player_engine_suggest,
          onOpenSettings: onOpenSettings,
        ),
        VideoPlayerLoadingWithThumbnail(
          :final thumbnailUrl,
          :final aspectRatio,
        ) =>
          BooruHero(
            tag: heroTag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Consumer(
                    builder: (_, ref, _) => BooruImage(
                      config: ref.watchConfigAuth,
                      borderRadius: BorderRadius.zero,
                      aspectRatio: aspectRatio,
                      imageUrl: thumbnailUrl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        VideoPlayerLoading() => const BooruHero(
          tag: null,
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      },
    );
  }
}

class _BufferingOverlay extends StatelessWidget {
  const _BufferingOverlay({
    required this.thumbnailUrl,
    required this.aspectRatio,
  });

  final String? thumbnailUrl;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          if (thumbnailUrl case final thumb?)
            Consumer(
              builder: (_, ref, _) => BooruImage(
                config: ref.watchConfigAuth,
                borderRadius: BorderRadius.zero,
                aspectRatio: aspectRatio,
                imageUrl: thumb,
              ),
            ),
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t.video_player.buffering,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
