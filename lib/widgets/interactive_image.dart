// Flutter imports:
import 'package:flutter/material.dart';

class InteractiveImage extends StatefulWidget {
  const InteractiveImage({
    super.key,
    required this.useOriginalSize,
    required this.image,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    required this.transformationController,
  });

  final bool useOriginalSize;
  final Widget image;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final TransformationController transformationController;

  @override
  State<InteractiveImage> createState() => _InteractiveImageState();
}

class _InteractiveImageState extends State<InteractiveImage>
    with SingleTickerProviderStateMixin {
  final hideOverlay = ValueNotifier(false);
  late final fullsize = ValueNotifier(widget.useOriginalSize);
  late final _transformationController = widget.transformationController;
  TapDownDetails? _doubleTapDetails;

  late final AnimationController _animationController;
  late Animation<Matrix4> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() => _transformationController.value = _animation.value);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.6,
      maxScale: 5,
      transformationController: _transformationController,
      child: ValueListenableBuilder<bool>(
        valueListenable: hideOverlay,
        builder: (context, hide, child) => Stack(
          children: [
            GestureDetector(
              onDoubleTapDown: (details) => _doubleTapDetails = details,
              onDoubleTap: () {
                if (widget.onDoubleTap != null) {
                  widget.onDoubleTap!();
                } else {
                  _handleDoubleTap();
                }
              },
              onLongPress: () {
                if (widget.onLongPress != null) {
                  widget.onLongPress!();
                }
              },
              onTap: () => widget.onTap?.call(),
              child: child,
            ),
          ],
        ),
        child: Align(
          child: ValueListenableBuilder<bool>(
            valueListenable: fullsize,
            builder: (context, useFullsize, _) {
              return widget.image;
            },
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    Matrix4 endMatrix;
    final position = _doubleTapDetails!.localPosition;

    // ignore: prefer-conditional-expressions
    if (_transformationController.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurveTween(curve: Curves.easeInOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
    _transformationController.value = endMatrix;
  }
}
