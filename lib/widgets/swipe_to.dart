// Flutter imports:
import 'package:flutter/material.dart';

class SwipeTo extends StatefulWidget {
  const SwipeTo({
    super.key,
    required this.child,
    this.onRightSwipe,
    this.onLeftSwipe,
    required this.rightSwipeWidget,
    required this.leftSwipeWidget,
    this.animationDuration = const Duration(milliseconds: 150),
    this.enabled = true,
    this.swipeLeftEnabled = true,
    this.swipeRightEnabled = true,
  });
  final Widget child;
  final Duration animationDuration;
  final Widget? rightSwipeWidget;
  final Widget? leftSwipeWidget;
  final GestureDragEndCallback? onRightSwipe;
  final GestureDragEndCallback? onLeftSwipe;

  final bool enabled;
  final bool swipeLeftEnabled;
  final bool swipeRightEnabled;

  @override
  State<SwipeTo> createState() => _SwipeToState();
}

class _SwipeToState extends State<SwipeTo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Offset _dragStartOffset = Offset.zero;
  Offset _dragUpdateOffset = Offset.zero;

  double get maxSwipeThreshold => 0.35;

  double calculateIconOpacity(double swipeDistanceFraction) {
    return (swipeDistanceFraction * 3).clamp(0.0, 1.0);
  }

  late var enabled = widget.enabled;
  // Left = -1, Right = 1
  int? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void didUpdateWidget(covariant SwipeTo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled != widget.enabled) {
      setState(() {
        enabled = widget.enabled;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartOffset = details.globalPosition;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // Determine the swipe direction
    _swipeDirection ??= details.delta.dx > 0 ? 1 : -1;

    if (_swipeDirection == 1 && !widget.swipeRightEnabled) {
      return;
    } else if (_swipeDirection == -1 && !widget.swipeLeftEnabled) {
      return;
    }

    double dx =
        (details.globalPosition.dx - _dragStartOffset.dx) / context.size!.width;

    // clamp dx to prevent swiping from the opposite direction
    if (_swipeDirection == 1) {
      dx = dx.clamp(0, maxSwipeThreshold);
    } else {
      dx = dx.clamp(-maxSwipeThreshold, 0);
    }

    setState(() {
      _dragUpdateOffset = Offset(dx, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final dx = _dragUpdateOffset.dx;
    if (dx.abs() > 0.3) {
      final swipeRight = dx > 0;
      if (swipeRight && widget.onRightSwipe != null) {
        widget.onRightSwipe!(details);
      } else if (!swipeRight && widget.onLeftSwipe != null) {
        widget.onLeftSwipe!(details);
      }
      _controller.forward().then((_) => _controller.reverse());
    } else {
      _controller.reverse();
    }
    setState(() {
      _dragUpdateOffset = Offset.zero;
      _swipeDirection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the swipe distance as a fraction of the screen width
    final swipeDistanceFraction = _dragUpdateOffset.dx.abs();

    // Determine the opacity based on the swipe distance
    final iconOpacity = calculateIconOpacity(swipeDistanceFraction);

    // Adjust the positions based on the swipe
    final rightIconPosition = 50 * _dragUpdateOffset.dx;
    final leftIconPosition = -50 * _dragUpdateOffset.dx;

    return GestureDetector(
      onHorizontalDragStart: enabled ? _handleDragStart : null,
      onHorizontalDragUpdate: enabled ? _handleDragUpdate : null,
      onHorizontalDragEnd: enabled ? _handleDragEnd : null,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          SlideTransition(
            position: AlwaysStoppedAnimation(_dragUpdateOffset),
            child: widget.child,
          ),
          Positioned(
            left: _dragUpdateOffset.dx >= 0 ? rightIconPosition : null,
            right: _dragUpdateOffset.dx < 0 ? leftIconPosition : null,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Opacity(
                  opacity: iconOpacity,
                  child: _dragUpdateOffset.dx > 0
                      ? widget.rightSwipeWidget
                      : widget.leftSwipeWidget,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
