// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/videos/videos.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class PostMedia extends ConsumerWidget {
  const PostMedia({
    super.key,
    required this.post,
    required this.placeholderImageUrl,
    required this.imageUrl,
    this.onCurrentVideoPositionChanged,
    this.onVideoVisibilityChanged,
    this.useHero = false,
    this.imageOverlayBuilder,
    this.autoPlay = false,
    this.onVideoPlayerCreated,
    this.onWebmVideoPlayerCreated,
    this.inFocus = false,
  });

  final Post post;
  final String? placeholderImageUrl;
  final String imageUrl;
  final bool useHero;
  final void Function(double current, double total, String url)?
      onCurrentVideoPositionChanged;
  final void Function(bool value)? onVideoVisibilityChanged;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final bool autoPlay;
  final void Function(VideoPlayerController controller)? onVideoPlayerCreated;
  final void Function(WebmVideoController controller)? onWebmVideoPlayerCreated;
  final bool inFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = post.isVideo
        ? !inFocus
            ? BooruImage(
                imageUrl: post.videoThumbnailUrl,
                fit: BoxFit.contain,
              )
            : extension(post.videoUrl) == '.webm'
                ? !isDesktopPlatform()
                    ? isAndroid()
                        ? EmbeddedWebViewWebm(
                            url: post.videoUrl,
                            onCurrentPositionChanged:
                                onCurrentVideoPositionChanged,
                            onVisibilityChanged: onVideoVisibilityChanged,
                            backgroundColor: context.colorScheme.surface,
                            onWebmVideoPlayerCreated: onWebmVideoPlayerCreated,
                            autoPlay: autoPlay,
                            sound: ref.isGlobalVideoSoundOn,
                            playbackSpeed:
                                ref.watchPlaybackSpeed(post.videoUrl),
                            userAgent: ref
                                .watch(
                                    userAgentGeneratorProvider(ref.watchConfig))
                                .generate(),
                          )
                        : BooruVideo(
                            url: post.videoUrl,
                            aspectRatio: post.aspectRatio,
                            onCurrentPositionChanged:
                                onCurrentVideoPositionChanged,
                            onVisibilityChanged: onVideoVisibilityChanged,
                            autoPlay: autoPlay,
                            onVideoPlayerCreated: onVideoPlayerCreated,
                            sound: ref.isGlobalVideoSoundOn,
                            speed: ref.watchPlaybackSpeed(post.videoUrl),
                          )
                    : BooruVideo(
                        url: post.videoUrl,
                        aspectRatio: post.aspectRatio,
                        onCurrentPositionChanged: onCurrentVideoPositionChanged,
                        onVisibilityChanged: onVideoVisibilityChanged,
                        autoPlay: autoPlay,
                        onVideoPlayerCreated: onVideoPlayerCreated,
                        sound: ref.isGlobalVideoSoundOn,
                        speed: ref.watchPlaybackSpeed(post.videoUrl),
                      )
                : PerformanceOrientationBuilder(
                    builder: (context, orientation) => BooruVideo(
                      url: post.videoUrl,
                      aspectRatio: post.aspectRatio,
                      onCurrentPositionChanged: onCurrentVideoPositionChanged,
                      onVisibilityChanged: onVideoVisibilityChanged,
                      autoPlay: autoPlay,
                      onVideoPlayerCreated: onVideoPlayerCreated,
                      sound: ref.isGlobalVideoSoundOn,
                      speed: ref.watchPlaybackSpeed(post.videoUrl),
                      customControlsBuilder:
                          orientation.isPortrait ? null : () => null,
                    ),
                  )
        : InteractiveBooruImage(
            useHero: useHero,
            heroTag: '${post.id}_hero',
            aspectRatio: post.aspectRatio,
            imageUrl: imageUrl,
            placeholderImageUrl: placeholderImageUrl,
            imageOverlayBuilder: (constraints) =>
                imageOverlayBuilder?.call(constraints) ?? [],
            width: post.width,
            height: post.height,
          );

    return PerformanceOrientationBuilder(
      builder: (_, orientation) => media,
    );
  }
}
