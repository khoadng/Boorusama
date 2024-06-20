// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/feats/video/videos_provider.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/embedded_webview_webm.dart';

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
                      )
                : OrientationBuilder(
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
                    ),
                  )
        : InteractiveBooruImage(
            useHero: useHero,
            heroTag: "${post.id}_hero",
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

    return OrientationBuilder(
      builder: (_, orientation) => Padding(
        padding: orientation == Orientation.portrait
            ? EdgeInsets.zero
            : EdgeInsets.only(
                bottom: 8 + MediaQuery.viewPaddingOf(context).bottom,
              ),
        child: media,
      ),
    );
  }
}
