// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../themes/theme/types.dart';
import 'slideshow_controller.dart';

const _kFadeDuration = Duration(milliseconds: 300);
const _kAutoHideDelay = Duration(seconds: 2);
const _kUserTriggerHideDelay = Duration(seconds: 5);

class SlideshowOverlay extends StatefulWidget {
  const SlideshowOverlay({
    required this.controller,
    required this.child,
    super.key,
    this.onStop,
  });

  final SlideshowController controller;
  final Widget child;
  final VoidCallback? onStop;

  @override
  State<SlideshowOverlay> createState() => _SlideshowOverlayState();
}

class _SlideshowOverlayState extends State<SlideshowOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _hideTimer;
  late final ValueNotifier<bool> _showStopIcon;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _showStopIcon = ValueNotifier(false);
    _animationController = AnimationController(
      duration: _kFadeDuration,
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _showStopIcon.addListener(_onIconVisibilityChanged);
    widget.controller.state.addListener(_onSlideshowStateChanged);

    if (widget.controller.isRunning) {
      _showStopIcon.value = true;
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _showStopIcon.removeListener(_onIconVisibilityChanged);
    widget.controller.state.removeListener(_onSlideshowStateChanged);
    _showStopIcon.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onIconVisibilityChanged() {
    if (_showStopIcon.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onSlideshowStateChanged() {
    if (widget.controller.isRunning) {
      _showStopIcon.value = true;
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
      _showStopIcon.value = false;
    }
  }

  void _startHideTimer({Duration? duration}) {
    _hideTimer?.cancel();
    _hideTimer = Timer(duration ?? _kAutoHideDelay, () {
      if (mounted && widget.controller.isRunning) {
        _showStopIcon.value = false;
      }
    });
  }

  void _onScreenTap() {
    if (widget.controller.isRunning) {
      _showStopIcon.value = true;
      _startHideTimer(duration: _kUserTriggerHideDelay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.state,
      builder: (context, state, child) => Stack(
        children: [
          IgnorePointer(
            ignoring: state.isRunning,
            child: widget.child,
          ),
          if (state.isRunning)
            Positioned.fill(
              child: GestureDetector(
                onTap: _onScreenTap,
                onDoubleTap: () {
                  if (widget.onStop case final callback?) {
                    callback();
                  } else {
                    widget.controller.stop();
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Container(),
              ),
            ),
          if (state.isRunning)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                if (_fadeAnimation.value == 0) return const SizedBox.shrink();

                return Positioned(
                  right: 20,
                  child: SafeArea(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          _SlideshowButton(
                            icon: Symbols.pause,
                            onTap: () {
                              if (widget.onStop case final callback?) {
                                callback();
                              } else {
                                widget.controller.stop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SlideshowButton extends StatelessWidget {
  const _SlideshowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.extendedColorScheme;

    return Material(
      color: scheme.surfaceContainerOverlay,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: scheme.onSurfaceContainerOverlay,
            fill: 1,
          ),
        ),
      ),
    );
  }
}
