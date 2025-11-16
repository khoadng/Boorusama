// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../videos/player/widgets.dart';
import 'post_details_controller.dart';

class PlayPauseAnimationOverlay extends StatelessWidget {
  const PlayPauseAnimationOverlay({
    required this.controller,
    super.key,
  });

  final PostDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return VideoActionAnimationOverlay(
      duration: kPlayPauseAnimationDuration,
      triggerNotifier: controller.playPauseAction,
      showEnd: 0.1,
      hideStart: 0.8,
      iconBuilder: (action, progress) {
        return Center(
          child: _PlayPauseIcon(
            icon: switch (action) {
              PlayPauseAction.play => Symbols.play_arrow,
              PlayPauseAction.pause => Symbols.pause,
            },
            progress: progress,
          ),
        );
      },
    );
  }
}

class _PlayPauseIcon extends StatelessWidget {
  const _PlayPauseIcon({
    required this.icon,
    required this.progress,
  });

  final IconData icon;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scale = 0.8 + (progress * 0.4); // 0.8 to 1.2

    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6 * progress),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: progress),
          size: 32,
          fill: 1,
        ),
      ),
    );
  }
}
