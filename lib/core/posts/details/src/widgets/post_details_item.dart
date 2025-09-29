// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../foundation/platform.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../configs/gesture/gesture.dart';
import '../../../../videos/player/widgets.dart';
import '../../../../widgets/widgets.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../../details.dart';
import 'post_details_controller.dart';
import 'post_media.dart';
import 'seek_animation_overlay.dart';

class PostDetailsItem<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsItem({
    required this.index,
    required this.posts,
    required this.transformController,
    required this.isInitPageListenable,
    required this.imageCacheManager,
    required this.detailsController,
    required this.authConfig,
    required this.gestureConfig,
    required this.imageUrlBuilder,
    super.key,
  });

  final int index;
  final List<T> posts;
  final TransformationController transformController;
  final ValueListenable<bool> isInitPageListenable;
  final ImageCacheManager? imageCacheManager;
  final PostDetailsController<T> detailsController;
  final BooruConfigAuth authConfig;
  final PostGestureConfig? gestureConfig;
  final String Function(T post) imageUrlBuilder;

  @override
  ConsumerState<PostDetailsItem<T>> createState() => _PostDetailsItemState<T>();
}

class _PostDetailsItemState<T extends Post>
    extends ConsumerState<PostDetailsItem<T>> {
  final _videoKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final pageViewController = PostDetailsPageViewScope.of(context);
    final post = widget.posts[widget.index];

    final booruRepo = ref.watch(booruRepoProvider(widget.authConfig));
    final gestures = widget.gestureConfig?.fullview;

    void onItemTap() {
      final controller = widget.detailsController;

      if (isDesktopPlatform()) {
        if (controller.currentPost.value.isVideo) {
          if (controller.isVideoPlaying.value) {
            controller.pauseCurrentVideo();
          } else {
            controller.playCurrentVideo();
          }
        } else {
          if (pageViewController.isExpanded) return;

          pageViewController.toggleOverlay();
        }
      } else {
        if (pageViewController.isExpanded) return;

        pageViewController.toggleOverlay();
      }
    }

    void onVideoDoubleTap(Offset? tapPosition) {
      final renderBox =
          _videoKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || tapPosition == null) return;

      widget.detailsController.seekFromDoubleTap(
        tapPosition,
        renderBox.size,
      );
    }

    final initialThumbnailUrl = widget.detailsController.initialThumbnailUrl;

    return ValueListenableBuilder(
      valueListenable: pageViewController.sheetState,
      builder: (_, state, _) => GestureDetector(
        // let the user tap the image to toggle overlay
        onTap: onItemTap,
        child: InteractiveViewerExtended(
          key: _videoKey,
          contentSize: Size(post.width, post.height),
          controller: widget.transformController,
          enable: switch (state.isExpanded) {
            true => context.isLargeScreen,
            false => true,
          },
          onTransformationChanged: pageViewController.onTransformationChanged,
          onTap: onItemTap,
          onDoubleTap: switch ((
            doubleTap: gestures.canDoubleTap,
            handler: booruRepo?.handlePostGesture,
          )) {
            (doubleTap: true, handler: final h?) => (_) => h(
              ref,
              gestures?.doubleTap,
              post,
            ),
            (doubleTap: false, handler: _) when post.isVideo =>
              (details) => onVideoDoubleTap(details?.localPosition),
            _ => null,
          },
          onLongPress: gestures.canLongPress && booruRepo != null
              ? () => booruRepo.handlePostGesture(
                  ref,
                  gestures?.longPress,
                  post,
                )
              : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ValueListenableBuilder(
                valueListenable: widget.isInitPageListenable,
                builder: (_, isInitPage, _) {
                  return PostMedia<T>(
                    post: post,
                    config: widget.authConfig,
                    imageUrlBuilder: widget.imageUrlBuilder,
                    imageCacheManager: widget.imageCacheManager,
                    // This is used to make sure we have a thumbnail to show instead of a black placeholder
                    thumbnailUrlBuilder:
                        isInitPage && initialThumbnailUrl != null
                        ? (_) => initialThumbnailUrl
                        : null,
                    controller: pageViewController,
                  );
                },
              ),
              if (post.isVideo)
                Align(
                  alignment: Alignment.bottomRight,
                  child: state.isExpanded && !context.isLargeScreen
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              // duplicate codes, maybe refactor later
                              PlayPauseButton(
                                isPlaying:
                                    widget.detailsController.isVideoPlaying,
                                onPlayingChanged: (value) {
                                  if (value) {
                                    widget.detailsController.pauseVideo(
                                      post.id,
                                    );
                                  } else if (!value) {
                                    widget.detailsController.playVideo(post.id);
                                  } else {
                                    // do nothing
                                  }
                                },
                              ),
                              const SoundControlButton(
                                padding: EdgeInsets.all(8),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              if (post.isVideo)
                SeekAnimationOverlay(
                  controller: widget.detailsController,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
