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
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/videos/videos.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../../foundation/networking/networking.dart';
import '../settings/widgets/image_viewer_page.dart';

class PostMedia extends ConsumerWidget {
  const PostMedia({
    super.key,
    required this.post,
    required this.placeholderImageUrl,
    required this.imageUrl,
    this.onImageTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onImageZoomUpdated,
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
  final VoidCallback? onImageTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool useHero;
  final void Function(bool value)? onImageZoomUpdated;
  final void Function(double current, double total, String url)?
      onCurrentVideoPositionChanged;
  final void Function(bool value)? onVideoVisibilityChanged;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final bool autoPlay;
  final void Function(VideoPlayerController controller)? onVideoPlayerCreated;
  final void Function(WebmVideoController controller)? onWebmVideoPlayerCreated;
  final bool inFocus;

  void _openSettings(BuildContext context) {
    openImageViewerSettingsPage(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final useDefault = ref.watch(settingsProvider
        .select((value) => value.videoPlayerEngine != VideoPlayerEngine.mdk));
    final headers = ref.watch(cachedBypassDdosHeadersProvider(config.url));

    final media = post.isVideo
        ? !inFocus
            ? BooruImage(
                imageUrl: post.videoThumbnailUrl,
                fit: BoxFit.contain,
              )
            : extension(post.videoUrl) == '.webm' && useDefault
                ? !isDesktopPlatform()
                    ? isAndroid()
                        ? EmbeddedWebViewWebm(
                            url: post.videoUrl,
                            onCurrentPositionChanged:
                                onCurrentVideoPositionChanged,
                            onVisibilityChanged: onVideoVisibilityChanged,
                            backgroundColor:
                                context.colors.videoPlayerBackgroundColor,
                            onWebmVideoPlayerCreated: onWebmVideoPlayerCreated,
                            autoPlay: autoPlay,
                            sound: ref.isGlobalVideoSoundOn,
                            playbackSpeed:
                                ref.watchPlaybackSpeed(post.videoUrl),
                            userAgent: ref
                                .watch(
                                    userAgentGeneratorProvider(ref.watchConfig))
                                .generate(),
                            onZoomUpdated: onImageZoomUpdated,
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
                            onZoomUpdated: onImageZoomUpdated,
                            onOpenSettings: () => _openSettings(context),
                            headers: headers,
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
                        onZoomUpdated: onImageZoomUpdated,
                        onOpenSettings: () => _openSettings(context),
                        headers: headers,
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
                      onZoomUpdated: onImageZoomUpdated,
                      customControlsBuilder:
                          orientation.isPortrait ? null : () => null,
                      onOpenSettings: () => _openSettings(context),
                      headers: headers,
                    ),
                  )
        : InteractiveBooruImage(
            useHero: useHero,
            heroTag: '${post.id}_hero',
            aspectRatio: post.aspectRatio,
            imageUrl: imageUrl,
            placeholderImageUrl: placeholderImageUrl,
            onTap: onImageTap,
            onDoubleTap: onDoubleTap,
            onLongPress: onLongPress,
            imageOverlayBuilder: (constraints) =>
                imageOverlayBuilder?.call(constraints) ?? [],
            width: post.width,
            height: post.height,
            onZoomUpdated: onImageZoomUpdated,
          );

    return PerformanceOrientationBuilder(
      builder: (_, orientation) => media,
    );
  }
}
