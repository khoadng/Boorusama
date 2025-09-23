// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../configs/config/types.dart';
import '../../../../settings/routes.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/widgets.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../types/post_details.dart';
import 'post_details_image.dart';
import 'video_controls.dart';

class PostMedia<T extends Post> extends ConsumerWidget {
  const PostMedia({
    required this.post,
    required this.config,
    required this.imageUrlBuilder,
    required this.thumbnailUrlBuilder,
    required this.controller,
    required this.imageCacheManager,
    super.key,
  });

  final T post;
  final BooruConfigAuth config;
  final PostDetailsPageViewController controller;
  final String Function(T post)? imageUrlBuilder;
  final String Function(T post)? thumbnailUrlBuilder;
  final ImageCacheManager? imageCacheManager;

  void _openSettings(WidgetRef ref) {
    openImageViewerSettingsPage(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PostDetails.of<T>(context);
    final heroTag = '${post.id}_hero';

    ref
      ..listen(globalSoundStateProvider, (previous, next) {
        if (previous != next) {
          details.controller.updatePlayerSound(next);
        }
      })
      ..listen(playbackSpeedProvider(post.videoUrl), (
        previous,
        next,
      ) {
        if (previous != next) {
          details.controller.updatePlayerSpeed(next);
        }
      });

    return post.isVideo
        ? Stack(
            children: [
              Positioned.fill(
                child: BooruVideo(
                  heroTag: heroTag,
                  player: details.controller.getPlayerForPost(post.id),
                  aspectRatio: post.aspectRatio ?? 16.0 / 9.0,
                  thumbnailUrl: post.videoThumbnailUrl,
                  onOpenSettings: () => _openSettings(ref),
                  error: details.controller.getPlayerError(post.id),
                  isBuffering: details.controller.isPlayerBuffering(
                    post.id,
                  ),
                ),
              ),
              if (context.isLargeScreen)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder(
                    valueListenable: controller.overlay,
                    builder: (context, overlay, child) =>
                        overlay ? child! : const SizedBox.shrink(),
                    child: PostDetailsVideoControls(
                      controller: details.controller,
                    ),
                  ),
                ),
            ],
          )
        : PostDetailsImage(
            heroTag: heroTag,
            imageUrlBuilder: imageUrlBuilder,
            thumbnailUrlBuilder: thumbnailUrlBuilder,
            imageCacheManager: imageCacheManager,
            post: post,
            config: config,
          );
  }
}
