// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
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
    this.onImageZoomUpdated,
    this.onCurrentVideoPositionChanged,
    this.onVideoVisibilityChanged,
    this.useHero = false,
    this.imageOverlayBuilder,
    this.autoPlay = false,
  });

  final Post post;
  final String? placeholderImageUrl;
  final String imageUrl;
  final VoidCallback? onImageTap;
  final bool useHero;
  final void Function(bool value)? onImageZoomUpdated;
  final void Function(double current, double total, String url)?
      onCurrentVideoPositionChanged;
  final void Function(bool value)? onVideoVisibilityChanged;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  //TODO: this only apply to mp4 video
  final bool autoPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return post.isVideo
        ? extension(post.videoUrl) == '.webm'
            ? !isDesktopPlatform()
                ? EmbeddedWebViewWebm(
                    url: post.videoUrl,
                    onCurrentPositionChanged: onCurrentVideoPositionChanged,
                    onVisibilityChanged: onVideoVisibilityChanged,
                    backgroundColor: context.colors.videoPlayerBackgroundColor,
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: BooruImage(
                          aspectRatio: post.aspectRatio,
                          imageUrl: post.thumbnailImageUrl,
                          placeholderUrl: post.thumbnailImageUrl,
                          previewCacheManager:
                              ref.watch(previewImageCacheManagerProvider),
                        ),
                      ),
                      const Center(
                        child: Card(
                          child:
                              Text('Cant play WEBM video on desktop for now'),
                        ),
                      ),
                    ],
                  )
            : BooruVideo(
                url: post.videoUrl,
                aspectRatio: post.aspectRatio,
                onCurrentPositionChanged: onCurrentVideoPositionChanged,
                onVisibilityChanged: onVideoVisibilityChanged,
                autoPlay: autoPlay,
              )
        : InteractiveBooruImage(
            useHero: useHero,
            heroTag: "${post.id}_hero",
            aspectRatio: post.aspectRatio,
            imageUrl: imageUrl,
            placeholderImageUrl: placeholderImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: ref.watch(previewImageCacheManagerProvider),
            imageOverlayBuilder: (constraints) =>
                imageOverlayBuilder?.call(constraints) ?? [],
            width: post.width,
            height: post.height,
            onZoomUpdated: onImageZoomUpdated,
          );
  }
}
