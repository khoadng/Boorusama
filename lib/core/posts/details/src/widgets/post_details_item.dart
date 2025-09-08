// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../foundation/platform.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../configs/gesture/gesture.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../settings/src/types/types.dart';
import '../../../../videos/play_pause_button.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/sound_control_button.dart';
import '../../../../widgets/widgets.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../../details.dart';
import 'post_details_controller.dart';
import 'post_media.dart';

class PostDetailsItem<T extends Post> extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final pageViewController = PostDetailsPageViewScope.of(context);
    final post = posts[index];

    final videoPlayerEngine = ref.watch(
      settingsProvider.select((value) => value.videoPlayerEngine),
    );

    final booruBuilder = ref.watch(booruBuilderProvider(authConfig));
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = gestureConfig?.fullview;

    void onItemTap() {
      final controller = detailsController;

      if (isDesktopPlatform()) {
        if (controller.currentPost.value.isVideo) {
          if (controller.isVideoPlaying.value) {
            controller.pauseCurrentVideo(
              useDefaultEngine: videoPlayerEngine.isDefault,
            );
          } else {
            controller.playCurrentVideo(
              useDefaultEngine: videoPlayerEngine.isDefault,
            );
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

    final initialThumbnailUrl = detailsController.initialThumbnailUrl;

    return ValueListenableBuilder(
      valueListenable: pageViewController.sheetState,
      builder: (_, state, _) => GestureDetector(
        // let the user tap the image to toggle overlay
        onTap: onItemTap,
        child: InteractiveViewerExtended(
          contentSize: Size(post.width, post.height),
          controller: transformController,
          enable: switch (state.isExpanded) {
            true => context.isLargeScreen,
            false => true,
          },
          onTransformationChanged: pageViewController.onTransformationChanged,
          onTap: onItemTap,
          onDoubleTap: gestures.canDoubleTap && postGesturesHandler != null
              ? () => postGesturesHandler(
                  ref,
                  gestures?.doubleTap,
                  post,
                )
              : null,
          onLongPress: gestures.canLongPress && postGesturesHandler != null
              ? () => postGesturesHandler(
                  ref,
                  gestures?.longPress,
                  post,
                )
              : null,
          child: _buildPostContent(
            context,
            ref,
            post,
            authConfig,
            imageUrlBuilder,
            imageCacheManager,
            isInitPageListenable,
            initialThumbnailUrl,
            pageViewController,
            detailsController,
            videoPlayerEngine,
            onItemTap,
          ),
        ),
      ),
    );
  }

  Widget _buildPostContent<T extends Post>(
    BuildContext context,
    WidgetRef ref,
    T post,
    BooruConfigAuth authConfig,
    String Function(T post)? imageUrlBuilder,
    ImageCacheManager? imageCacheManager,
    ValueListenable<bool> isInitPageListenable,
    String? initialThumbnailUrl,
    PostDetailsPageViewController pageViewController,
    PostDetailsController<T> detailsController,
    VideoPlayerEngine videoPlayerEngine,
    VoidCallback onItemTap,
  ) {
    // Check if this is a very tall image that should use webtoon viewer
    final isVeryTallImage = !post.isVideo &&
        post.height != null &&
        post.width != null &&
        post.width! > 0 &&
        (post.height! / post.width!) > 2.0; // Lower threshold for more aggressive webtoon mode

    if (isVeryTallImage) {
      // For very tall images, use scrollable view instead of InteractiveViewer
      return GestureDetector(
        onTap: onItemTap, // Still allow tap to show/hide overlay
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, // Status bar height
            ),
            child: ValueListenableBuilder(
              valueListenable: isInitPageListenable,
              builder: (_, isInitPage, _) {
                return PostMedia<T>(
                  post: post,
                  config: authConfig,
                  imageUrlBuilder: imageUrlBuilder,
                  imageCacheManager: imageCacheManager,
                  thumbnailUrlBuilder:
                      isInitPage && initialThumbnailUrl != null
                      ? (Post _) => initialThumbnailUrl
                      : null,
                  controller: pageViewController,
                );
              },
            ),
          ),
        ),
      );
    }

    // Normal (non-tall) image layout
    return Stack(
      alignment: Alignment.center,
      children: [
        ValueListenableBuilder(
          valueListenable: isInitPageListenable,
          builder: (_, isInitPage, _) {
            return PostMedia<T>(
              post: post,
              config: authConfig,
              imageUrlBuilder: imageUrlBuilder,
              imageCacheManager: imageCacheManager,
              // This is used to make sure we have a thumbnail to show instead of a black placeholder
              thumbnailUrlBuilder:
                  isInitPage && initialThumbnailUrl != null
                  // Need to specify the type here to avoid type inference error
                  // ignore: avoid_types_on_closure_parameters
                  ? (Post _) => initialThumbnailUrl
                  : null,
              controller: pageViewController,
            );
          },
        ),
        if (post.isVideo)
          Align(
            alignment: Alignment.bottomRight,
            child: ValueListenableBuilder(
              valueListenable: pageViewController.sheetState,
              builder: (_, state, _) => state.isExpanded && !context.isLargeScreen
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          // duplicate codes, maybe refactor later
                          PlayPauseButton(
                            isPlaying: detailsController.isVideoPlaying,
                            onPlayingChanged: (value) {
                              if (value) {
                                detailsController.pauseVideo(
                                  post.id,
                                  post.isWebm,
                                  videoPlayerEngine.isDefault,
                                );
                              } else if (!value) {
                                detailsController.playVideo(
                                  post.id,
                                  post.isWebm,
                                  videoPlayerEngine.isDefault,
                                );
                              } else {
                                // do nothing
                              }
                            },
                          ),
                          VideoSoundScope(
                            builder: (context, soundOn) =>
                                SoundControlButton(
                                  padding: const EdgeInsets.all(8),
                                  soundOn: soundOn,
                                  onSoundChanged: (value) =>
                                      ref.setGlobalVideoSound(value),
                                ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}
