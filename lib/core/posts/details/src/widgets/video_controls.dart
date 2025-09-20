// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../theme.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/widgets.dart';
import '../../../../widgets/widgets.dart';
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
          builder: (context, constraints) => SafeArea(
            top: false,
            left: isLarge,
            right: isLarge,
            bottom: isLarge,
            child: Container(
              padding: isLarge ? const EdgeInsets.all(8) : null,
              child: _buildControls(
                isLarge,
                constraints,
                rightControls,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(
    bool isLarge,
    BoxConstraints constraints,
    List<Widget> rightControls,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Spacer(),
            if (constraints.maxWidth < _kMinWidth) ...rightControls,
          ],
        ),
        const SizedBox(height: 4),
        Consumer(
          builder: (context, ref, child) {
            final useDefaultEngine = ref.watch(
              settingsProvider.select(
                (value) =>
                    value.viewer.videoPlayerEngine != VideoPlayerEngine.mdk,
              ),
            );

            return Row(
              children: [
                const SizedBox(width: 4),
                _buildPlayPauseButton(isLarge, useDefaultEngine),
                _buildLeftTime(),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildBar(useDefaultEngine),
                ),
                const SizedBox(width: 4),
                _buildRightTime(),
                if (constraints.maxWidth >= _kMinWidth) ...rightControls,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRightTime() {
    return ValueListenableBuilder(
      valueListenable: controller.videoProgress,
      builder: (_, progress, _) => VideoTimeText(
        duration: progress.duration,
        forceHigherThanOneSecond: progress.duration.inSeconds != 0,
      ),
    );
  }

  Widget _buildLeftTime() {
    return ValueListenableBuilder(
      valueListenable: controller.videoProgress,
      builder: (_, progress, _) => VideoTimeText(
        duration: progress.position,
        forceHigherThanOneSecond: false,
      ),
    );
  }

  Widget _buildPlayPauseButton(bool isLarge, bool useDefaultEngine) {
    return ValueListenableBuilder(
      valueListenable: controller.currentPost,
      builder: (_, post, _) => PlayPauseButton(
        padding: !isLarge ? const EdgeInsets.all(8) : null,
        isPlaying: controller.isVideoPlaying,
        onPlayingChanged: (value) {
          if (value) {
            controller.pauseVideo(post.id);
          } else if (!value) {
            controller.playVideo(post.id);
          } else {
            // do nothing
          }
        },
      ),
    );
  }

  Widget _buildBar(bool useDefaultEngine) {
    return Container(
      color: Colors.transparent,
      height: 28,
      child: MultiValueListenableBuilder3(
        first: controller.currentPost,
        second: controller.videoProgress,
        third: controller.isVideoInitializing,
        builder: (context, post, progress, initializing) {
          final colorScheme = Theme.of(context).colorScheme;

          return VideoProgressBar(
            indeterminate: initializing,
            duration: progress.duration,
            position: progress.position,
            buffered: const [],
            onDragStart: () {
              controller.pauseVideo(post.id);
            },
            onDragEnd: () {
              controller.playVideo(post.id);
            },
            seekTo: (position) => controller.onVideoSeekTo(position, post.id),
            barHeight: 3,
            handleHeight: 6,
            drawShadow: true,
            backgroundColor: colorScheme.hintColor.withValues(alpha: 0.2),
            playedColor: colorScheme.primary,
            bufferedColor: colorScheme.hintColor,
            handleColor: colorScheme.primary,
          );
        },
      ),
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
