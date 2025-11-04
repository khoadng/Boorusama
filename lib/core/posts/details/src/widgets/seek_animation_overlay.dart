// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../videos/player/widgets.dart';
import 'post_details_controller.dart';

class SeekAnimationOverlay extends StatelessWidget {
  const SeekAnimationOverlay({
    required this.controller,
    super.key,
  });

  final PostDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return VideoActionAnimationOverlay(
      duration: kSeekAnimationDuration,
      triggerNotifier: controller.seekDirection,
      iconBuilder: (direction, progress) {
        return Stack(
          children: [
            if (direction == SeekDirection.backward)
              _PositionedSeekIcon(
                isLeft: true,
                icon: Symbols.fast_rewind,
                progress: progress,
              ),
            if (direction == SeekDirection.forward)
              _PositionedSeekIcon(
                isLeft: false,
                icon: Symbols.fast_forward,
                progress: progress,
              ),
          ],
        );
      },
    );
  }
}

const _kPadding = 60.0;

class _PositionedSeekIcon extends StatelessWidget {
  const _PositionedSeekIcon({
    required this.isLeft,
    required this.icon,
    required this.progress,
  });

  final bool isLeft;
  final IconData icon;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: isLeft ? _kPadding : null,
      right: isLeft ? null : _kPadding,
      top: 0,
      bottom: 0,
      child: Center(
        child: _SeekIcon(
          icon: icon,
          progress: progress,
        ),
      ),
    );
  }
}

class _SeekIcon extends StatelessWidget {
  const _SeekIcon({
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
