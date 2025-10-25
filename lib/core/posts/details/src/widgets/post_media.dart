// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../configs/config/types.dart';
import '../../../../http/providers.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/routes.dart';
import '../../../../videos/cache/providers.dart';
import '../../../../videos/player/providers.dart';
import '../../../../videos/player/widgets.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/types.dart';
import '../providers/video_url_provider.dart';
import '../types/post_details.dart';
import '../types/utils.dart';
import 'post_details_image.dart';

class PostMedia<T extends Post> extends ConsumerWidget {
  const PostMedia({
    required this.post,
    required this.config,
    required this.viewer,
    required this.imageUrlBuilder,
    required this.thumbnailUrlBuilder,
    required this.controller,
    required this.imageCacheManager,
    super.key,
    this.isPageSettled = false,
  });

  final T post;
  final BooruConfigAuth config;
  final BooruConfigViewer viewer;
  final PostDetailsPageViewController controller;
  final String Function(T post)? imageUrlBuilder;
  final String Function(T post)? thumbnailUrlBuilder;
  final ImageCacheManager? imageCacheManager;
  final bool isPageSettled;

  void _openSettings(WidgetRef ref) {
    openImageViewerSettingsPage(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PostDetails.of<T>(context);
    final headers = ref.watch(httpHeadersProvider(config));
    final heroTag = '${post.id}_hero';

    return post.isVideo
        ? Stack(
            children: [
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    final videoUrl = ref.watch(
                      postDetailsVideoUrlProvider(
                        VideoUrlParam(
                          viewer: viewer,
                          post: post,
                          auth: config,
                        ),
                      ),
                    );

                    return BooruVideo(
                      heroTag: heroTag,
                      url: videoUrl,
                      aspectRatio: post.aspectRatio,
                      onCurrentPositionChanged: (current, total) =>
                          details.controller.onCurrentPositionChanged(
                            current,
                            total,
                            post.id.toString(),
                          ),
                      onVideoPlayerCreated: (player) => details.controller
                          .onBooruVideoPlayerCreated(player, post.id),
                      onVideoPlayerDisposed: () => details.controller
                          .onBooruVideoPlayerDisposed(post.id),
                      sound: ref.watch(globalSoundStateProvider),
                      speed: ref.watch(playbackSpeedProvider(videoUrl)),
                      thumbnailUrl: post.videoThumbnailUrl,
                      onOpenSettings: () => _openSettings(ref),
                      headers: headers,
                      videoPlayerEngine: ref.watch(
                        imageViewerSettingsProvider.select(
                          (value) => value.videoPlayerEngine,
                        ),
                      ),
                      userAgent: ref.watch(
                        userAgentProvider(config),
                      ),
                      logger: ref.watch(loggerProvider),
                      cacheManager: ref.watch(videoCacheManagerProvider),
                      cacheDelay: createVideoCacheDelayCallback(post),
                      fileSize: post.fileSize > 0 ? post.fileSize : null,
                      shouldInitialize: isPageSettled,
                    );
                  },
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
