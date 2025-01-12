// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../theme.dart';
import '../../../../videos/more_options_control_button.dart';
import '../../../../videos/play_pause_button.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/sound_control_button.dart';
import '../../../../videos/video_progress_bar.dart';
import '../../../post/post.dart';
import 'post_details_controller.dart';

class PostDetailsVideoControls<T extends Post> extends ConsumerWidget {
  const PostDetailsVideoControls({
    required this.controller,
    super.key,
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
      const SizedBox(width: 8),
    ];

    final isLarge = context.isLargeScreen;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    final useDefaultEngine = ref.watch(
      settingsProvider.select(
        (value) => value.videoPlayerEngine != VideoPlayerEngine.mdk,
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SafeArea(
              top: false,
              left: isLarge,
              right: isLarge,
              bottom: isLarge,
              child: Container(
                padding: isLarge ? const EdgeInsets.all(8) : null,
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
                        const SizedBox(width: 4),
                        ValueListenableBuilder(
                          valueListenable: controller.currentPost,
                          builder: (_, post, __) => PlayPauseButton(
                            padding: !isLarge ? const EdgeInsets.all(8) : null,
                            isPlaying: controller.isVideoPlaying,
                            onPlayingChanged: (value) {
                              if (value) {
                                controller.pauseVideo(
                                  post.id,
                                  post.isWebm,
                                  useDefaultEngine,
                                );
                              } else if (!value) {
                                controller.playVideo(
                                  post.id,
                                  post.isWebm,
                                  useDefaultEngine,
                                );
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
                            forceHigherThanOneSecond: false,
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
                                    controller.pauseVideo(
                                      post.id,
                                      post.isWebm,
                                      useDefaultEngine,
                                    );
                                  },
                                  onDragEnd: () {
                                    // resume the video when dragging ends
                                    controller.playVideo(
                                      post.id,
                                      post.isWebm,
                                      useDefaultEngine,
                                    );
                                  },
                                  seekTo: (position) =>
                                      controller.onVideoSeekTo(
                                    position,
                                    post.id,
                                    post.isWebm,
                                    useDefaultEngine,
                                  ),
                                  barHeight: 3,
                                  handleHeight: 6,
                                  drawShadow: true,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .hintColor
                                      .withValues(alpha: 0.2),
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
                            forceHigherThanOneSecond: true,
                          ),
                        ),
                        if (constraints.maxWidth >= _kMinWidth)
                          ...rightControls,
                      ],
                    ),
                  ],
                ),
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
    required this.duration,
    super.key,
    this.forceHigherThanOneSecond,
  });

  final Duration duration;
  final bool? forceHigherThanOneSecond;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatDurationForMedia(
              duration,
              forceHigherThanOneSecond: forceHigherThanOneSecond ?? false,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}
