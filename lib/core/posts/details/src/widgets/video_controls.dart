// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../themes/theme/types.dart';
import '../../../../videos/player/providers.dart';
import '../../../../videos/player/widgets.dart';
import '../../../../widgets/widgets.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/types.dart';
import 'post_details_controller.dart';

class PostDetailsVideoControlsMobile<T extends Post> extends ConsumerWidget {
  const PostDetailsVideoControlsMobile({
    required this.controller,
    super.key,
  });

  final PostDetailsController<T> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _VideoControls(
      child: LayoutBuilder(
        builder: (context, constraints) => _VideoControlsContent(
          controller: controller,
          constraints: constraints,
          playPausePadding: const EdgeInsets.all(8),
          popoverController: null,
        ),
      ),
    );
  }
}

class PostDetailsVideoControlsDesktop<T extends Post> extends StatefulWidget {
  const PostDetailsVideoControlsDesktop({
    required this.controller,
    required this.pageViewController,
    super.key,
  });

  final PostDetailsController<T> controller;
  final PostDetailsPageViewController pageViewController;

  @override
  State<PostDetailsVideoControlsDesktop<T>> createState() =>
      _PostDetailsVideoControlsDesktopState<T>();
}

class _PostDetailsVideoControlsDesktopState<T extends Post>
    extends State<PostDetailsVideoControlsDesktop<T>> {
  final _popoverController = AnchorController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.pageViewController.overlay,
      builder: (context, overlay, child) => ListenableBuilder(
        listenable: _popoverController,
        builder: (context, _) => switch ((
          overlay: overlay,
          optionShowing: _popoverController.isShowing,
        )) {
          (overlay: true, optionShowing: _) ||
          (overlay: false, optionShowing: true) => _VideoControls(
            child: LayoutBuilder(
              builder: (context, constraints) => SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: _VideoControlsContent(
                    popoverController: _popoverController,
                    controller: widget.controller,
                    constraints: constraints,
                    playPausePadding: null,
                  ),
                ),
              ),
            ),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        child,
      ],
    );
  }
}

class _VideoControlsContent<T extends Post> extends ConsumerWidget {
  const _VideoControlsContent({
    required this.controller,
    required this.constraints,
    required this.playPausePadding,
    required this.popoverController,
  });

  final PostDetailsController<T> controller;
  final BoxConstraints constraints;
  final EdgeInsets? playPausePadding;
  final AnchorController? popoverController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rightControls = [
      const SoundControlButton(),
      const SizedBox(width: 8),
      ValueListenableBuilder(
        valueListenable: controller.currentPost,
        builder: (context, post, child) => MoreOptionsControlButton(
          post: post,
          popoverController: popoverController,
          speed: ref.watch(
            playbackSpeedProvider(
              post.videoUrl,
            ),
          ),
          onSpeedChanged: (speed) => ref
              .read(
                playbackSpeedProvider(post.videoUrl).notifier,
              )
              .setSpeed(speed),
        ),
      ),
      const SizedBox(width: 8),
    ];

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
        Row(
          children: [
            const SizedBox(width: 4),
            _buildPlayPauseButton(),
            _buildLeftTime(),
            const SizedBox(width: 4),
            Expanded(
              child: _buildBar(),
            ),
            const SizedBox(width: 4),
            _buildRightTime(),
            if (constraints.maxWidth >= _kMinWidth) ...rightControls,
          ],
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

  Widget _buildPlayPauseButton() {
    return ValueListenableBuilder(
      valueListenable: controller.currentPost,
      builder: (_, post, _) => PlayPauseButton(
        padding: playPausePadding,
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

  Widget _buildBar() {
    return Container(
      color: Colors.transparent,
      height: 28,
      child: MultiValueListenableBuilder2(
        first: controller.currentPost,
        second: controller.videoProgress,
        builder: (context, post, progress) {
          final colorScheme = Theme.of(context).colorScheme;

          return VideoProgressBar(
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
