// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/videos/more_options_control_button.dart';
import 'package:boorusama/core/videos/play_pause_button.dart';
import 'package:boorusama/core/videos/providers.dart';
import 'package:boorusama/core/videos/sound_control_button.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../post.dart';
import 'post_details.dart';

class PostDetailsVideoControls<T extends Post> extends ConsumerWidget {
  const PostDetailsVideoControls({
    super.key,
    required this.controller,
  });

  final PostDetailsController<T> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rightControls = [
      VideoSoundScope(
        builder: (context, soundOn) => SoundControlButton(
          soundOn: soundOn,
          onSoundChanged: (value) => ref.setGlobalVideoSound(value),
        ),
      ),
      const SizedBox(width: 8),
      MoreOptionsControlButton(
        speed: ref.watchPlaybackSpeed(
          controller.currentPost.value.videoUrl,
        ),
        onSpeedChanged: (speed) => ref.setPlaybackSpeed(
          controller.currentPost.value.videoUrl,
          speed,
        ),
      ),
      const SizedBox(width: 8)
    ];

    final isLarge = context.isLargeScreen;
    final surfaceColor = context.colorScheme.surface;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor.applyOpacity(0.8),
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SafeArea(
              top: false,
              left: isLarge,
              right: false,
              bottom: isLarge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      if (constraints.maxWidth < _kMinWidth) ...rightControls,
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      ValueListenableBuilder(
                        valueListenable: controller.currentPost,
                        builder: (_, post, __) => PlayPauseButton(
                          isPlaying: controller.isVideoPlaying,
                          onPlayingChanged: (value) {
                            if (value == true) {
                              controller.pauseVideo(post.id, post.isWebm);
                            } else if (value == false) {
                              controller.playVideo(post.id, post.isWebm);
                            } else {
                              // do nothing
                            }
                          },
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: controller.videoProgress,
                        builder: (_, progress, __) => VideoTimeText(
                          duration: progress.position,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          height: 28,
                          child: ValueListenableBuilder(
                            valueListenable: controller.currentPost,
                            builder: (_, post, __) => ValueListenableBuilder(
                              valueListenable: controller.videoProgress,
                              builder: (_, progress, __) => VideoProgressBar(
                                duration: progress.duration,
                                position: progress.position,
                                buffered: const [],
                                onDragStart: () {
                                  // pause the video when dragging
                                  controller.pauseVideo(post.id, post.isWebm);
                                },
                                onDragEnd: () {
                                  // resume the video when dragging ends
                                  controller.playVideo(post.id, post.isWebm);
                                },
                                seekTo: (position) => controller.onVideoSeekTo(
                                  position,
                                  post.id,
                                  post.isWebm,
                                ),
                                barHeight: 2,
                                handleHeight: 6,
                                drawShadow: true,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .hintColor
                                    .applyOpacity(0.2),
                                playedColor:
                                    Theme.of(context).colorScheme.primary,
                                bufferedColor:
                                    Theme.of(context).colorScheme.hintColor,
                                handleColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ValueListenableBuilder(
                        valueListenable: controller.videoProgress,
                        builder: (_, progress, __) => VideoTimeText(
                          duration: progress.duration,
                        ),
                      ),
                      if (constraints.maxWidth >= _kMinWidth) ...rightControls,
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

const _kMinWidth = 320.0;

class VideoTimeText extends StatelessWidget {
  const VideoTimeText({
    super.key,
    required this.duration,
  });

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatDurationForMedia(duration),
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
