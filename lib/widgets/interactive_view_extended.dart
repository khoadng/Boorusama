// Flutter imports:
import 'package:flutter/material.dart';

class InteractiveViewExtended extends StatefulWidget {
  const InteractiveViewExtended({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.controller,
    this.onZoomUpdated,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final void Function(bool zoomed)? onZoomUpdated;
  final TransformationController? controller;

  @override
  State<InteractiveViewExtended> createState() =>
      _InteractiveViewExtendedState();
}

class _InteractiveViewExtendedState extends State<InteractiveViewExtended>
    with SingleTickerProviderStateMixin {
  late final _controller = widget.controller ?? TransformationController();
  TapDownDetails? _doubleTapDetails;

  late final AnimationController _animationController;
  late Animation<Matrix4> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_onAnimationChanged);

    _controller.addListener(_onChanged);
  }

  void _onAnimationChanged() => _controller.value = _animation.value;

  void _onChanged() {
    final clampedMatrix = Matrix4.diagonal3Values(
      _controller.value.right.x,
      _controller.value.up.y,
      _controller.value.forward.z,
    );

    widget.onZoomUpdated?.call(!clampedMatrix.isIdentity());
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationChanged);
    _animationController.dispose();

    _controller.removeListener(_onChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.6,
      maxScale: 5,
      transformationController: _controller,
      child: GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: () {
          if (widget.onDoubleTap != null) {
            widget.onDoubleTap!();
          } else {
            _handleDoubleTap();
          }
        },
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    Matrix4 endMatrix;
    final position = _doubleTapDetails!.localPosition;

    // ignore: prefer-conditional-expressions
    if (_controller.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }

    _animation = Matrix4Tween(
      begin: _controller.value,
      end: endMatrix,
    ).animate(
      CurveTween(curve: Curves.easeInOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
    _controller.value = endMatrix;
  }
}
