// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../configs/config.dart';
import '../../../../configs/current.dart';
import '../../../../configs/ref.dart';
import '../../../../foundation/display.dart';
import '../../../../foundation/path.dart';
import '../../../../foundation/platform.dart';
import '../../../../http/providers.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/routes.dart';
import '../../../../settings/settings.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/video_player.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../types/post_details.dart';
import 'post_details_image.dart';
import 'video_controls.dart';

class PostMedia<T extends Post> extends ConsumerWidget {
  const PostMedia({
    required this.post,
    required this.imageUrlBuilder,
    required this.thumbnailUrlBuilder,
    required this.controller,
    required this.imageCacheManager,
    super.key,
  });

  final T post;
  final PostDetailsPageViewController controller;
  final String Function(T post)? imageUrlBuilder;
  final String Function(T post)? thumbnailUrlBuilder;
  final ImageCacheManager Function(Post post)? imageCacheManager;

  void _openSettings(BuildContext context) {
    openImageViewerSettingsPage(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PostDetails.of<T>(context);
    final booruType = ref.watch(
      currentBooruConfigProvider.select((value) => value.auth.booruType),
    );
    final useDefault = ref.watch(
      settingsProvider
          .select((value) => value.videoPlayerEngine != VideoPlayerEngine.mdk),
    );
    final config = ref.watchConfigAuth;
    final headers = ref.watch(cachedBypassDdosHeadersProvider(config.url));
    final heroTag = '${post.id}_hero';

    return post.isVideo
        ? Stack(
            children: [
              Positioned.fill(
                child: extension(post.videoUrl) == '.webm' &&
                        isAndroid() &&
                        useDefault
                    ? EmbeddedWebViewWebm(
                        heroTag: heroTag,
                        url: post.videoUrl,
                        onCurrentPositionChanged:
                            details.controller.onCurrentPositionChanged,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        onWebmVideoPlayerCreated: (wvpc) => details.controller
                            .onWebmVideoPlayerCreated(wvpc, post.id),
                        sound: ref.isGlobalVideoSoundOn,
                        playbackSpeed: ref.watchPlaybackSpeed(post.videoUrl),
                        userAgent: ref.watch(userAgentProvider(booruType)),
                      )
                    : BooruVideo(
                        heroTag: heroTag,
                        url: post.videoUrl,
                        aspectRatio: post.aspectRatio,
                        onCurrentPositionChanged:
                            details.controller.onCurrentPositionChanged,
                        onVideoPlayerCreated: (vpc) => details.controller
                            .onVideoPlayerCreated(vpc, post.id),
                        sound: ref.isGlobalVideoSoundOn,
                        speed: ref.watchPlaybackSpeed(post.videoUrl),
                        thumbnailUrl: post.videoThumbnailUrl,
                        onOpenSettings: () => _openSettings(context),
                        headers: headers,
                        onInitializing: details.controller.onInitializing,
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
          );
  }
}
