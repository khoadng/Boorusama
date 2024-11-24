// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class PostMedia<T extends Post> extends ConsumerWidget {
  const PostMedia({
    super.key,
    required this.post,
    required this.imageUrl,
    this.useHero = false,
    this.imageOverlayBuilder,
    this.autoPlay = false,
    required this.controller,
  });

  final T post;
  final String imageUrl;
  final bool useHero;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final bool autoPlay;
  final PostDetailsPageViewController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PostDetails.of<T>(context);

    return post.isVideo
        ? extension(post.videoUrl) == '.webm' && isAndroid()
            ? EmbeddedWebViewWebm(
                url: post.videoUrl,
                onCurrentPositionChanged:
                    details.controller.onCurrentPositionChanged,
                onVisibilityChanged: (value) =>
                    controller.overlay.value = !value,
                backgroundColor: context.colorScheme.surface,
                onWebmVideoPlayerCreated: (wvpc) =>
                    details.controller.onWebmVideoPlayerCreated(wvpc, post.id),
                autoPlay: autoPlay,
                sound: ref.isGlobalVideoSoundOn,
                playbackSpeed: ref.watchPlaybackSpeed(post.videoUrl),
                userAgent: ref
                    .watch(userAgentGeneratorProvider(ref.watchConfig))
                    .generate(),
              )
            : PerformanceOrientationBuilder(
                builder: (context, orientation) => BooruVideo(
                  url: post.videoUrl,
                  aspectRatio: post.aspectRatio,
                  onCurrentPositionChanged:
                      details.controller.onCurrentPositionChanged,
                  onVisibilityChanged: (value) =>
                      controller.overlay.value = !value,
                  autoPlay: autoPlay,
                  onVideoPlayerCreated: (vpc) =>
                      details.controller.onVideoPlayerCreated(vpc, post.id),
                  sound: ref.isGlobalVideoSoundOn,
                  customControlsBuilder:
                      orientation.isPortrait ? null : () => null,
                  speed: ref.watchPlaybackSpeed(post.videoUrl),
                ),
              )
        : InteractiveBooruImage(
            useHero: useHero,
            heroTag: '${post.id}_hero',
            aspectRatio: post.aspectRatio,
            imageUrl: imageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            imageOverlayBuilder: (constraints) =>
                imageOverlayBuilder?.call(constraints) ?? [],
            width: post.width,
            height: post.height,
          );
  }
}
