// Dart imports:
import 'dart:async';
import 'dart:math';
import 'dart:ui' show PointerDeviceKind;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../settings/settings.dart';
import '../../../details_pageview/src/post_details_page_view_controller.dart';

class TallMediaScroller extends StatefulWidget {
  const TallMediaScroller({
    required this.child,
    required this.pageViewController,
    required this.settings,
    required this.overlayListenable,
    required this.enableHaptics,
    required this.isVerticalSwipeMode,
    this.onRequestExpandSheet,
    super.key,
  });

  final Widget child;
  final PostDetailsPageViewController pageViewController;
  final TallMediaSettings settings;
  final ValueListenable<bool> overlayListenable;
  final bool enableHaptics;
  final bool isVerticalSwipeMode;
  final VoidCallback? onRequestExpandSheet;

  @override
  State<TallMediaScroller> createState() => _TallMediaScrollerState();
}

class _TallMediaScrollerState extends State<TallMediaScroller> {
  static const _kEdgeSlack = 12.0;
  static const _kHintVisibleDuration = Duration(milliseconds: 1800);

  late final ScrollController _scrollController = ScrollController();
  late final ValueNotifier<bool> _canScrollUp = ValueNotifier<bool>(false);
  late final ValueNotifier<bool> _canScrollDown = ValueNotifier<bool>(false);

  Offset? _gestureStartPosition;
  Duration? _gestureStartTimestamp;
  bool _trackingGesture = false;
  bool _hasTriggeredLock = false;
  bool _requestedExpandDuringGesture = false;

  Timer? _hintTimer;
  bool _showInitialHint = false;

  TallMediaSettings get _settings => widget.settings;
  PostDetailsPageViewController get _controller => widget.pageViewController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
    widget.overlayListenable.addListener(_handleOverlayChanged);

    _showInitialHint = widget.isVerticalSwipeMode;
    if (_showInitialHint) {
      _hintTimer = Timer(_kHintVisibleDuration, () {
        if (!mounted) return;
        setState(() => _showInitialHint = false);
      });
    }
  }

  @override
  void didUpdateWidget(covariant TallMediaScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overlayListenable != widget.overlayListenable) {
      oldWidget.overlayListenable.removeListener(_handleOverlayChanged);
      widget.overlayListenable.addListener(_handleOverlayChanged);
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    widget.overlayListenable.removeListener(_handleOverlayChanged);
    _scrollController
      ..removeListener(_updateScrollIndicators)
      ..dispose();
    _canScrollUp.dispose();
    _canScrollDown.dispose();
    super.dispose();
  }

  void _handleOverlayChanged() {
    if (!widget.overlayListenable.value) return;

    // Reset gesture tracking when overlay becomes visible
    _endGesture(cancelled: true);
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final offset = position.pixels;
    final maxExtent = position.maxScrollExtent;
    final activationExtent = _edgeActivationExtent(position);

    final canScrollUp = offset > activationExtent;
    final canScrollDown = offset < max(0.0, maxExtent - activationExtent);

    if (_canScrollUp.value != canScrollUp) {
      _canScrollUp.value = canScrollUp;
    }

    if (_canScrollDown.value != canScrollDown) {
      _canScrollDown.value = canScrollDown;
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.isVerticalSwipeMode) return;
    if (event.kind != PointerDeviceKind.touch &&
        event.kind != PointerDeviceKind.stylus) {
      return;
    }

    _trackingGesture = true;
    _gestureStartPosition = event.position;
    _gestureStartTimestamp = event.timeStamp;
    _ensureSwipeLock();
    _requestedExpandDuringGesture = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_trackingGesture) return;
    if (_gestureStartPosition == null) return;

    // Lock swipe if user drags beyond threshold even when detection is late
    final dragDistance = (event.position.dy - _gestureStartPosition!.dy).abs();
    if (!_hasTriggeredLock &&
        dragDistance > _settings.scrollLockDistanceThreshold) {
      _ensureSwipeLock();
    }

    if (!_hasTriggeredLock && _gestureStartTimestamp != null) {
      final elapsed = event.timeStamp - _gestureStartTimestamp!;
      final elapsedMs = max(elapsed.inMilliseconds, 1);
      final velocity = (dragDistance / elapsedMs) * 1000;
      if (velocity > _settings.scrollLockVelocityThreshold) {
        _ensureSwipeLock();
      }
    }

    if (widget.onRequestExpandSheet != null &&
        widget.overlayListenable.value &&
        !_requestedExpandDuringGesture) {
      final delta = event.position.dy - _gestureStartPosition!.dy;
      if (delta < -12) {
        _requestedExpandDuringGesture = true;
        widget.onRequestExpandSheet!.call();
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_trackingGesture) return;
    final shouldNavigate =
        widget.isVerticalSwipeMode && _shouldTriggerNavigation(event);

    if (shouldNavigate) {
      _trackingGesture = false;
      _requestedExpandDuringGesture = false;
      _gestureStartPosition = null;
      _gestureStartTimestamp = null;
      _performNavigation(event.position.dy);
    } else {
      _endGesture(cancelled: false);
      _releaseSwipeLock();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _endGesture(cancelled: true);
  }

  void _ensureSwipeLock() {
    if (_hasTriggeredLock) return;
    _controller.setSwipeLock(SwipeLockReason.tallContent, true);
    _hasTriggeredLock = true;
  }

  void _releaseSwipeLock() {
    if (!_hasTriggeredLock) return;
    _controller.setSwipeLock(SwipeLockReason.tallContent, false);
    _hasTriggeredLock = false;
  }

  void _endGesture({required bool cancelled}) {
    _trackingGesture = false;
    if (cancelled) {
      _releaseSwipeLock();
    } else {
      // keep the lock until navigation decision is made in _handlePointerUp
      if (!widget.isVerticalSwipeMode) {
        _releaseSwipeLock();
      }
    }

    _gestureStartPosition = null;
    _gestureStartTimestamp = null;
    _requestedExpandDuringGesture = false;
  }

  bool _shouldTriggerNavigation(PointerUpEvent event) {
    if (_gestureStartPosition == null ||
        _gestureStartTimestamp == null ||
        !_scrollController.hasClients) {
      return false;
    }

    final offset = _scrollController.offset;
    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    final activationExtent = _edgeActivationExtent(position);
    final atTop = offset <= activationExtent;
    final atBottom = offset >= max(0.0, maxExtent - activationExtent);

    if (!atTop && !atBottom) {
      return false;
    }

    final deltaY = event.position.dy - _gestureStartPosition!.dy;
    final duration = event.timeStamp - _gestureStartTimestamp!;
    final timeMs = max(duration.inMilliseconds, 1);
    final velocity = (deltaY / timeMs) * 1000;
    final distance = deltaY.abs();

    final meetsDistance = distance >= _settings.navigationDistanceThreshold;
    final meetsVelocity =
        velocity.abs() >= _settings.navigationVelocityThreshold;

    final isSwipeDown = deltaY > 0;

    if (atTop && isSwipeDown && (meetsVelocity || meetsDistance)) {
      return true;
    }

    if (atBottom && !isSwipeDown && (meetsVelocity || meetsDistance)) {
      return true;
    }

    return false;
  }

  void _performNavigation(double pointerY) {
    _releaseSwipeLock();

    final delta = pointerY - (_gestureStartPosition?.dy ?? pointerY);
    final goingDown = delta > 0;

    if (goingDown) {
      if (_controller.page > 0) {
        _controller.previousPage();
        _maybeHaptic();
      }
    } else {
      if (_controller.page < _controller.totalPage - 1) {
        _controller.nextPage();
        _maybeHaptic();
      }
    }
  }

  void _maybeHaptic() {
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  double _edgeActivationExtent(ScrollPosition position) {
    return max(
      _kEdgeSlack,
      position.viewportDimension * _settings.edgeActivationRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.isVerticalSwipeMode ? _handlePointerDown : null,
      onPointerMove: widget.isVerticalSwipeMode ? _handlePointerMove : null,
      onPointerUp: widget.isVerticalSwipeMode ? _handlePointerUp : null,
      onPointerCancel: widget.isVerticalSwipeMode ? _handlePointerCancel : null,
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.overlayListenable,
        builder: (context, overlayVisible, _) {
          final physics = overlayVisible
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics();

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _updateScrollIndicators();
              }
              return false;
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: physics,
                  child: widget.child,
                ),
                _TallScrollIndicators(
                  showInitialHint: _showInitialHint,
                  canScrollUp: _canScrollUp,
                  canScrollDown: _canScrollDown,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TallScrollIndicators extends StatelessWidget {
  const _TallScrollIndicators({
    required this.showInitialHint,
    required this.canScrollUp,
    required this.canScrollDown,
  });

  final bool showInitialHint;
  final ValueListenable<bool> canScrollUp;
  final ValueListenable<bool> canScrollDown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hintColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return IgnorePointer(
      ignoring: true,
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: canScrollUp,
            builder: (context, value, _) => _IndicatorRibbon(
              alignment: Alignment.topCenter,
              visible: value,
              color: hintColor,
              showPulse: showInitialHint,
              icon: Icons.keyboard_double_arrow_up_rounded,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<bool>(
            valueListenable: canScrollDown,
            builder: (context, value, _) => _IndicatorRibbon(
              alignment: Alignment.bottomCenter,
              visible: value,
              color: hintColor,
              showPulse: showInitialHint,
              icon: Icons.keyboard_double_arrow_down_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorRibbon extends StatelessWidget {
  const _IndicatorRibbon({
    required this.visible,
    required this.alignment,
    required this.color,
    required this.icon,
    required this.showPulse,
  });

  final bool visible;
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final bool showPulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 200),
      alignment: alignment,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible || showPulse ? 1 : 0,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }
}
