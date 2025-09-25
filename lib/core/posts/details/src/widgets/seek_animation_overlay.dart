// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'post_details_controller.dart';

class SeekAnimationOverlay extends StatefulWidget {
  const SeekAnimationOverlay({
    required this.controller,
    super.key,
  });

  final PostDetailsController controller;

  @override
  State<SeekAnimationOverlay> createState() => _SeekAnimationOverlayState();
}

class _SeekAnimationOverlayState extends State<SeekAnimationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: kSeekAnimationDuration,
      vsync: this,
    );

    _opacityAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(
              0,
              0.3,
              curve: Curves.easeOut,
            ),
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.2,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(
              0,
              0.5,
              curve: Curves.easeOut,
            ),
          ),
        );

    widget.controller.seekDirection.addListener(_onSeekDirectionChanged);
  }

  @override
  void dispose() {
    widget.controller.seekDirection.removeListener(_onSeekDirectionChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onSeekDirectionChanged() {
    final direction = widget.controller.seekDirection.value;
    if (direction != null) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.seekDirection,
      builder: (context, direction, child) {
        if (direction == null) return const SizedBox.shrink();

        return Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final opacity = _opacityAnimation.value;
                final scale = _scaleAnimation.value;

                // Calculate fade out
                final fadeOutOpacity = _animationController.value > 0.7
                    ? (1 - (_animationController.value - 0.7) / 0.3)
                    : 1;

                final finalOpacity = opacity * fadeOutOpacity;

                return Stack(
                  children: [
                    if (direction == SeekDirection.backward)
                      _PositionedSeekIcon(
                        isLeft: true,
                        icon: Symbols.fast_rewind,
                        opacity: finalOpacity,
                        scale: scale,
                      ),
                    if (direction == SeekDirection.forward)
                      _PositionedSeekIcon(
                        isLeft: false,
                        icon: Symbols.fast_forward,
                        opacity: finalOpacity,
                        scale: scale,
                      ),
                  ],
                );
              },
            ),
          ),
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
    required this.opacity,
    required this.scale,
  });

  final bool isLeft;
  final IconData icon;
  final double opacity;
  final double scale;

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
          opacity: opacity,
          scale: scale,
        ),
      ),
    );
  }
}

class _SeekIcon extends StatelessWidget {
  const _SeekIcon({
    required this.icon,
    required this.opacity,
    required this.scale,
  });

  final IconData icon;
  final double opacity;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6 * opacity),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: opacity),
          size: 32,
          fill: 1,
        ),
      ),
    );
  }
}
