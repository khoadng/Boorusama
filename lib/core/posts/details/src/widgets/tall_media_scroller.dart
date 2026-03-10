// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../details_pageview/src/post_details_page_view_controller.dart';

const _kEdgeSlack = 12.0;
const _kNavigationDistanceThreshold = 240.0;
const _kNavigationVelocityThreshold = 2200.0;
const _kScrollLockDistanceThreshold = 28.0;
const _kEdgeActivationRatio = 0.12;

class TallMediaScroller extends StatefulWidget {
  const TallMediaScroller({
    required this.child,
    required this.pageViewController,
    required this.overlayListenable,
    required this.enableHaptics,
    required this.isVerticalSwipeMode,
    this.onRequestExpandSheet,
    super.key,
  });

  final Widget child;
  final PostDetailsPageViewController pageViewController;
  final ValueListenable<bool> overlayListenable;
  final bool enableHaptics;
  final bool isVerticalSwipeMode;
  final VoidCallback? onRequestExpandSheet;

  @override
  State<TallMediaScroller> createState() => _TallMediaScrollerState();
}

class _TallMediaScrollerState extends State<TallMediaScroller> {
  late final _scrollController = ScrollController();

  Offset? _gestureStartPosition;
  Duration? _gestureStartTimestamp;
  var _trackingGesture = false;
  var _hasTriggeredLock = false;

  PostDetailsPageViewController get _controller => widget.pageViewController;

  @override
  void initState() {
    super.initState();
    widget.overlayListenable.addListener(_handleOverlayChanged);
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
    widget.overlayListenable.removeListener(_handleOverlayChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleOverlayChanged() {
    if (!widget.overlayListenable.value) return;
    _endGesture(cancelled: true);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.isVerticalSwipeMode) return;

    _trackingGesture = true;
    _gestureStartPosition = event.position;
    _gestureStartTimestamp = event.timeStamp;
    _ensureSwipeLock();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_trackingGesture || _gestureStartPosition == null) return;

    final dragDistance = (event.position.dy - _gestureStartPosition!.dy).abs();
    if (!_hasTriggeredLock && dragDistance > _kScrollLockDistanceThreshold) {
      _ensureSwipeLock();
    }

    if (widget.onRequestExpandSheet != null) {
      final delta = event.position.dy - _gestureStartPosition!.dy;
      if (delta < -12) {
        widget.onRequestExpandSheet!.call();
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_trackingGesture) return;

    final shouldNavigate =
        widget.isVerticalSwipeMode && _shouldTriggerNavigation(event);

    if (shouldNavigate) {
      _performNavigation(event.position.dy);
    }

    _endGesture(cancelled: false);
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
    _releaseSwipeLock();
    _gestureStartPosition = null;
    _gestureStartTimestamp = null;
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

    if (!atTop && !atBottom) return false;

    final deltaY = event.position.dy - _gestureStartPosition!.dy;
    final duration = event.timeStamp - _gestureStartTimestamp!;
    final timeMs = max(duration.inMilliseconds, 1);
    final velocity = (deltaY / timeMs) * 1000;
    final distance = deltaY.abs();

    final meetsDistance = distance >= _kNavigationDistanceThreshold;
    final meetsVelocity = velocity.abs() >= _kNavigationVelocityThreshold;

    final isSwipeDown = deltaY > 0;

    return (atTop && isSwipeDown && (meetsVelocity || meetsDistance)) ||
        (atBottom && !isSwipeDown && (meetsVelocity || meetsDistance));
  }

  void _performNavigation(double pointerY) {
    _releaseSwipeLock();

    final delta = pointerY - (_gestureStartPosition?.dy ?? pointerY);

    if (delta > 0) {
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
      position.viewportDimension * _kEdgeActivationRatio,
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

          return SingleChildScrollView(
            controller: _scrollController,
            physics: physics,
            child: widget.child,
          );
        },
      ),
    );
  }
}
