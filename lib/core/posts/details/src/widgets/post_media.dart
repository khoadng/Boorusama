// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../configs/config/types.dart';
import '../../../../configs/network/providers.dart';
import '../../../../ddos/handler/providers.dart';
import '../../../../developer_options/blocked_media_placeholder.dart';
import '../../../../developer_options/providers.dart';
import '../../../../http/client/providers.dart';
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
    required this.mediaAspectRatioBuilder,
    required this.videoAspectRatioBuilder,
    required this.placeholderMediaBuilder,
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
  final double? Function(T post)? mediaAspectRatioBuilder;
  final double? Function(T post)? videoAspectRatioBuilder;
  final PostDetailsPlaceholderMediaBuilder<T>? placeholderMediaBuilder;
  final ImageCacheManager? imageCacheManager;
  final bool isPageSettled;

  void _openSettings(WidgetRef ref) {
    openImageViewerSettingsPage(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PostDetails.of<T>(context);
    final heroTag = '${post.id}_hero';
    final automaticMediaLoadingEnabled = ref.watch(
      automaticMediaLoadingEnabledProvider,
    );

    if (!automaticMediaLoadingEnabled) {
      return BlockedMediaPlaceholder(
        aspectRatio: post.isVideo
            ? videoAspectRatioBuilder?.call(post) ??
                  post.effectiveVideoAspectRatio
            : mediaAspectRatioBuilder?.call(post) ??
                  post.effectiveSampleAspectRatio,
        isVideo: post.isVideo,
      );
    }

    final headers = ref.watch(httpHeadersProvider(config));

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

                    final request = ref
                        .watch(networkSettingsProvider(config))
                        .resolveMedia(videoUrl, headers: headers);
                    return BooruVideo(
                      heroTag: heroTag,
                      url: request.url,
                      aspectRatio:
                          videoAspectRatioBuilder?.call(post) ??
                          post.effectiveVideoAspectRatio,
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
                      headers: {
                        ...request.headers,
                        if (request.overridden)
                          ...ref.watch(
                            cachedBypassDdosHeadersProvider(request.url),
                          ),
                      },
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
            mediaAspectRatioBuilder: mediaAspectRatioBuilder,
            placeholderMediaBuilder: placeholderMediaBuilder,
            imageCacheManager: imageCacheManager,
            post: post,
            config: config,
          );
  }
}
