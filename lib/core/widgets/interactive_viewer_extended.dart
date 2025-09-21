// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';
import '../settings/settings.dart';

/// Fallback max zoom scale when content size is unknown. Limits zoom-in.
const _kFallbackMaxScale = 10.0;

/// Fallback min zoom scale when content size is unknown. Limits zoom-out.
const _kFallbackMinScale = 0.6;

/// Multiplier to adjust max zoom based on the ratio between content and container sizes.
const _kScaleMultiplier = 5.0;

/// Default zoom scale for double tap if content and container sizes are unknown.
const _kDoubleTapScale = 3.0;

/// Factor to determine when content is much larger than the container.
const _kImageExceedsContainerThreshold = 3.0;

class TransformationDetails {
  const TransformationDetails({
    required this.scale,
    required this.translation,
    required this.contentSize,
    required this.containerSize,
    required this.maxScale,
    required this.minScale,
    required this.transformationMatrix,
    required this.isZoomed,
  });

  final double scale;
  final Offset translation;
  final Size? contentSize;
  final Size? containerSize;
  final double maxScale;
  final double minScale;
  final Matrix4 transformationMatrix;
  final bool isZoomed;

  /// Whether the content is at maximum zoom level
  bool get isAtMaxZoom => scale >= maxScale * 0.95;

  /// Whether the content is at minimum zoom level
  bool get isAtMinZoom => scale <= minScale * 1.05;

  /// Calculate the maximum translation bounds for the current scale
  Offset get maxTranslation {
    final containter = containerSize;
    final content = contentSize;

    if (content == null || containter == null) return Offset.zero;

    if (!_isValidSize(contentSize) || !_isValidSize(containerSize)) {
      return Offset.zero;
    }

    final scaledWidth = content.width * scale;
    final scaledHeight = content.height * scale;

    final double maxX = max(0, (scaledWidth - containter.width) / 2);
    final double maxY = max(0, (scaledHeight - containter.height) / 2);

    return Offset(maxX, maxY);
  }

  /// Whether the current translation has hit the left boundary
  bool get isAtLeftBoundary => translation.dx >= maxTranslation.dx - 1;

  /// Whether the current translation has hit the right boundary
  bool get isAtRightBoundary => translation.dx <= -maxTranslation.dx + 1;

  /// Whether the current translation has hit the top boundary
  bool get isAtTopBoundary => translation.dy >= maxTranslation.dy - 1;

  /// Whether the current translation has hit the bottom boundary
  bool get isAtBottomBoundary => translation.dy <= -maxTranslation.dy + 1;

  /// Whether any boundary is currently hit
  bool get isAtAnyBoundary =>
      isAtLeftBoundary ||
      isAtRightBoundary ||
      isAtTopBoundary ||
      isAtBottomBoundary;

  @override
  String toString() =>
      'TransformationDetails(scale: $scale, translation: $translation, '
      'isZoomed: $isZoomed, isAtMaxZoom: $isAtMaxZoom, isAtAnyBoundary: $isAtAnyBoundary)';
}

class InteractiveViewerExtended extends ConsumerWidget {
  const InteractiveViewerExtended({
    required this.child,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.controller,
    this.onTransformationChanged,
    this.enable = true,
    this.contentSize,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final void Function(TransformationDetails details)? onTransformationChanged;
  final TransformationController? controller;
  final bool enable;
  final Size? contentSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);
    final enableHapticFeedback = hapticLevel.isReducedOrAbove;

    return RawInteractiveViewerExtended(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      controller: controller,
      onTransformationChanged: onTransformationChanged,
      enable: enable,
      contentSize: contentSize,
      enableHapticFeedback: enableHapticFeedback,
      child: child,
    );
  }
}

class RawInteractiveViewerExtended extends StatefulWidget {
  const RawInteractiveViewerExtended({
    required this.child,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.controller,
    this.onTransformationChanged,
    this.enable = true,
    this.contentSize,
    this.enableHapticFeedback = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final void Function(TransformationDetails details)? onTransformationChanged;
  final TransformationController? controller;

  // This is needed to keep the state of the child widget, remove this widget will cause its child to be recreated
  final bool enable;

  // The intrinsic size (e.g. resolution) of the content
  final Size? contentSize;

  // Enable haptic feedback for interactions
  final bool enableHapticFeedback;

  @override
  State<RawInteractiveViewerExtended> createState() =>
      _RawInteractiveViewerExtendedState();
}

class _RawInteractiveViewerExtendedState
    extends State<RawInteractiveViewerExtended>
    with SingleTickerProviderStateMixin {
  late var _controller = widget.controller ?? TransformationController();
  TapDownDetails? _doubleTapDetails;

  late final AnimationController _animationController;
  late Animation<Matrix4> _animation;

  late var enable = widget.enable;

  late var _enableHapticFeedback = widget.enableHapticFeedback;

  // Store the latest layout constraints.
  Size? _containerSize;

  // Track if max zoom haptic feedback has been triggered
  bool _hasTriggeredMaxZoomHaptic = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_onAnimationChanged);

    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant RawInteractiveViewerExtended oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onChanged);
      if (oldWidget.controller == null) {
        _controller.dispose();
      }

      final newController = widget.controller ?? TransformationController();
      _controller = newController;
      _controller.addListener(_onChanged);
    }

    if (oldWidget.enable != widget.enable) {
      setState(() {
        enable = widget.enable;
      });
    }

    if (oldWidget.enableHapticFeedback != widget.enableHapticFeedback) {
      _enableHapticFeedback = widget.enableHapticFeedback;
      _hasTriggeredMaxZoomHaptic = false;
    }
  }

  void _onAnimationChanged() => _controller.value = _animation.value;

  void _onChanged() {
    final currentScale = _controller.value.getMaxScaleOnAxis();
    final translationVector = _controller.value.getTranslation();
    final containerSize = _containerSize;
    final contentSize = widget.contentSize;

    final maxScale = _calcMaxScale(widget.contentSize, containerSize);

    final details = TransformationDetails(
      scale: currentScale,
      translation: Offset(translationVector.x, translationVector.y),
      contentSize: contentSize,
      containerSize: containerSize,
      maxScale: maxScale,
      minScale: _kFallbackMinScale,
      transformationMatrix: _controller.value,
      isZoomed: !Matrix4.diagonal3Values(
        _controller.value.right.x,
        _controller.value.up.y,
        _controller.value.forward.z,
      ).isIdentity(),
    );

    if (_enableHapticFeedback) {
      if (details.isAtMaxZoom && !_hasTriggeredMaxZoomHaptic) {
        HapticFeedback.selectionClick();
        _hasTriggeredMaxZoomHaptic = true;
      } else if (currentScale < maxScale * 0.9) {
        _hasTriggeredMaxZoomHaptic = false;
      }
    }

    widget.onTransformationChanged?.call(details);
  }

  @override
  void dispose() {
    _animationController
      ..removeListener(_onAnimationChanged)
      ..dispose();

    _controller.removeListener(_onChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        _containerSize = containerSize;

        return InteractiveViewer(
          minScale: _kFallbackMinScale,
          maxScale: _calcMaxScale(widget.contentSize, containerSize),
          transformationController: _controller,
          panEnabled: enable,
          scaleEnabled: enable,
          child: GestureDetector(
            onDoubleTapDown: enable
                ? (details) => _doubleTapDetails = details
                : null,
            onDoubleTap: enable
                ? () {
                    if (widget.onDoubleTap != null) {
                      widget.onDoubleTap!();
                    } else {
                      _handleDoubleTap();
                    }
                  }
                : null,
            onLongPress: enable ? widget.onLongPress : null,
            onTap: enable ? widget.onTap : null,
            child: widget.child,
          ),
        );
      },
    );
  }

  Matrix4 _calculateDoubleTapMatrix(Offset tapPosition) {
    // If already zoomed, reset transformation.
    if (!_controller.value.isIdentity()) {
      return Matrix4.identity();
    }

    final content = widget.contentSize;
    final viewport = _containerSize;

    // Check if both sizes are available.
    if (content != null &&
        viewport != null &&
        _isValidSize(content) &&
        _isValidSize(viewport)) {
      // Calculate aspect ratios
      final viewportAspectRatio = content.aspectRatio;
      final containerAspectRatio = viewport.aspectRatio;

      final heightRatio = containerAspectRatio / viewportAspectRatio;
      final widthRatio = viewportAspectRatio / containerAspectRatio;
      final isContentMuchWider = widthRatio > _kImageExceedsContainerThreshold;
      final isContentMuchTaller =
          heightRatio > _kImageExceedsContainerThreshold;

      // Check if content has a drastically different aspect ratio
      final needsSpecialZoom = isContentMuchWider || isContentMuchTaller;

      if (needsSpecialZoom) {
        return _calcZoomMatrixFromSize(
          viewport: viewport,
          content: content,
          focalPoint: tapPosition,
        );
      }
    }

    // Fallback to a fixed zoom.
    return _calcZoomMatrixFromZoomValue(
      focalPoint: tapPosition,
      zoomValue: _kDoubleTapScale,
    );
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    final position = _doubleTapDetails!.localPosition;
    final endMatrix = _calculateDoubleTapMatrix(position);

    _animation =
        Matrix4Tween(
          begin: _controller.value,
          end: endMatrix,
        ).animate(
          CurveTween(curve: Curves.easeInOut).animate(_animationController),
        );
    _animationController.forward(from: 0);
  }
}

// Calculates the target scale by fitting width for tall images and height for wide images.
Matrix4 _calcZoomMatrixFromSize({
  required Size viewport,
  required Size content,
  required Offset focalPoint,
}) {
  if (!_isValidSize(content) || !_isValidSize(viewport)) {
    return Matrix4.identity();
  }

  // Calculate scale factors to fit width and height
  final fitWidthScale = viewport.width / content.width;
  final fitHeightScale = viewport.height / content.height;

  // Determine current scale (content is already fit by either width or height)
  final currentScale = fitWidthScale < fitHeightScale
      ? fitWidthScale
      : fitHeightScale;

  // Calculate target scale (we want to fit the other dimension)
  final targetScale = fitWidthScale > fitHeightScale
      ? fitWidthScale
      : fitHeightScale;

  // Calculate zoom factor relative to current scale
  final zoomFactor = targetScale / currentScale;

  // Create transformation matrix centered at focal point
  return _calcZoomMatrixFromZoomValue(
    focalPoint: focalPoint,
    zoomValue: zoomFactor,
  );
}

Matrix4 _calcZoomMatrixFromZoomValue({
  required Offset focalPoint,
  required double zoomValue,
}) {
  return Matrix4.identity()
    ..translateByDouble(focalPoint.dx, focalPoint.dy, 0, 1)
    ..scaleByDouble(zoomValue, zoomValue, zoomValue, 1)
    ..translateByDouble(-focalPoint.dx, -focalPoint.dy, 0, 1);
}

double _calcMaxScale(Size? contentSize, Size? containerSize) {
  if (contentSize == null || containerSize == null) {
    return _kFallbackMaxScale;
  }

  if (!_isValidSize(contentSize) || !_isValidSize(containerSize)) {
    return _kFallbackMaxScale;
  }

  return max(
        contentSize.width / containerSize.width,
        contentSize.height / containerSize.height,
      ) *
      _kScaleMultiplier;
}

bool _isValidSize(Size? size) =>
    size != null && size.width != 0 && size.height != 0;
