// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../widgets/widgets.dart';
import '../../../../configs/config.dart';
import '../../../../configs/current.dart';
import '../../../../foundation/display.dart';
import '../../../../foundation/path.dart';
import '../../../../foundation/platform.dart';
import '../../../../http/providers.dart';
import '../../../../images/interactive_booru_image.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/video_player.dart';
import '../../../post/post.dart';
import '../post_details.dart';
import '../post_details_page_view.dart';
import 'video_controls.dart';

class PostMedia<T extends Post> extends ConsumerWidget {
  const PostMedia({
    super.key,
    required this.post,
    required this.imageUrl,
    this.useHero = false,
    this.imageOverlayBuilder,
    required this.controller,
  });

  final T post;
  final String imageUrl;
  final bool useHero;
  final List<Widget> Function(BoxConstraints constraints)? imageOverlayBuilder;
  final PostDetailsPageViewController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PostDetails.of<T>(context);
    final booruType = ref.watch(
      currentBooruConfigProvider.select((value) => value.auth.booruType),
    );

    return post.isVideo
        ? Stack(
            children: [
              Positioned.fill(
                child: extension(post.videoUrl) == '.webm' && isAndroid()
                    ? EmbeddedWebViewWebm(
                        url: post.videoUrl,
                        onCurrentPositionChanged:
                            details.controller.onCurrentPositionChanged,
                        onVisibilityChanged: (value) =>
                            controller.overlay.value = !value,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        onWebmVideoPlayerCreated: (wvpc) => details.controller
                            .onWebmVideoPlayerCreated(wvpc, post.id),
                        sound: ref.isGlobalVideoSoundOn,
                        playbackSpeed: ref.watchPlaybackSpeed(post.videoUrl),
                        userAgent: ref.watch(userAgentProvider(booruType)),
                      )
                    : BooruVideo(
                        url: post.videoUrl,
                        aspectRatio: post.aspectRatio,
                        onCurrentPositionChanged:
                            details.controller.onCurrentPositionChanged,
                        onVisibilityChanged: (value) =>
                            controller.overlay.value = !value,
                        onVideoPlayerCreated: (vpc) => details.controller
                            .onVideoPlayerCreated(vpc, post.id),
                        sound: ref.isGlobalVideoSoundOn,
                        speed: ref.watchPlaybackSpeed(post.videoUrl),
                        thumbnailUrl: post.videoThumbnailUrl,
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
