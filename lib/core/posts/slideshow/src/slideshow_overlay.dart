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
    with TickerProviderStateMixin {
  Timer? _hideTimer;
  late final ValueNotifier<bool> _showStopIcon;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _progressController;
  var _wasRunning = false;
  var _lastPage = 0;

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

    _progressController = AnimationController(
      duration: widget.controller.options.duration,
      vsync: this,
    );

    _showStopIcon.addListener(_onIconVisibilityChanged);
    widget.controller.state.addListener(_onSlideshowStateChanged);

    if (widget.controller.isRunning) {
      _showStopIcon.value = true;
      _startHideTimer();
      _lastPage = widget.controller.state.value.currentPage;
      _progressController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(SlideshowOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.state.removeListener(_onSlideshowStateChanged);
      widget.controller.state.addListener(_onSlideshowStateChanged);
      _progressController.duration = widget.controller.options.duration;
      if (widget.controller.isRunning) {
        _progressController.forward(from: 0);
      } else {
        _progressController.stop();
      }
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _showStopIcon.removeListener(_onIconVisibilityChanged);
    widget.controller.state.removeListener(_onSlideshowStateChanged);
    _showStopIcon.dispose();
    _animationController.dispose();
    _progressController.dispose();
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
    final isRunning = widget.controller.isRunning;
    final currentPage = widget.controller.state.value.currentPage;

    // Transitioned from not running to running
    if (isRunning && !_wasRunning) {
      _showStopIcon.value = true;
      _startHideTimer();
      _lastPage = currentPage;
      _progressController
        ..duration = widget.controller.options.duration
        ..forward(from: 0);
      // Transitioned from running to not running
    } else if (!isRunning && _wasRunning) {
      _hideTimer?.cancel();
      _showStopIcon.value = false;
      _progressController.stop();
      // Page changed while running, restart progress
    } else if (isRunning && currentPage != _lastPage) {
      _lastPage = currentPage;
      _progressController
        ..duration = widget.controller.options.duration
        ..forward(from: 0);
    }

    _wasRunning = isRunning;
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 4,
                        color: context
                            .extendedColorScheme
                            .onSurfaceContainerOverlay,
                        backgroundColor:
                            context.extendedColorScheme.surfaceContainerOverlay,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (state.isRunning)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                if (_fadeAnimation.value == 0) return const SizedBox.shrink();

                return Positioned(
                  top: 20,
                  right: 20,
                  child: SafeArea(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          _SlideshowButton(
                            icon: Symbols.close,
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
