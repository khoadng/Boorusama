// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/interactive_booru_image.dart';
import 'package:boorusama/boorus/core/widgets/posts/post_video.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/embedded_webview_webm.dart';

class PostMedia extends ConsumerWidget {
  const PostMedia({
    super.key,
    required this.post,
    required this.placeholderImageUrl,
    required this.imageUrl,
    required this.onImageTap,
    this.onImageZoomUpdated,
    this.onCurrentVideoPositionChanged,
    this.onVideoVisibilityChanged,
    this.useHero = false,
    this.imageOverlayBuilder,
  });

  final Post post;
  final String? placeholderImageUrl;
  final String imageUrl;
  final VoidCallback onImageTap;
  final bool useHero;
  final void Function(bool value)? onImageZoomUpdated;
  final void Function(double current, double total, String url)?
      onCurrentVideoPositionChanged;
  final void Function(bool value)? onVideoVisibilityChanged;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return post.isVideo
        ? extension(post.videoUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: post.videoUrl,
                onCurrentPositionChanged: onCurrentVideoPositionChanged,
                onVisibilityChanged: onVideoVisibilityChanged,
                backgroundColor: context.colors.videoPlayerBackgroundColor,
              )
            : BooruVideo(
                url: post.videoUrl,
                aspectRatio: post.aspectRatio,
                onCurrentPositionChanged: onCurrentVideoPositionChanged,
                onVisibilityChanged: onVideoVisibilityChanged,
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
