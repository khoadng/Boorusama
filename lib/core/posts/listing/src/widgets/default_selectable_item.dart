// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../widgets/shadow_gradient_overlay.dart';
import '../../../post/types.dart';
import '../routes/route_utils.dart';

const _kDefaultAnimationDuration = Duration(milliseconds: 200);

class DefaultSelectableItem<T extends Post> extends StatefulWidget {
  const DefaultSelectableItem({
    required this.index,
    required this.post,
    required this.item,
    required this.config,
    super.key,
    this.indicatorSize,
  });

  final int index;
  final T post;
  final Widget item;
  final double? indicatorSize;
  final BooruConfigAuth config;

  @override
  State<DefaultSelectableItem<T>> createState() =>
      _DefaultSelectableItemState<T>();
}

class _DefaultSelectableItemState<T extends Post>
    extends State<DefaultSelectableItem<T>>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _selectionController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _selectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // ignore: prefer_int_literals
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _scaleController.duration = Duration(
      milliseconds: (_kDefaultAnimationDuration.inMilliseconds * 0.4).round(),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _selectionController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SelectableBuilder(
      key: ValueKey(widget.post.id),
      index: widget.index,
      builder: (context, isSelected) {
        final selectionMode = SelectionMode.of(context);
        final isInSelectionMode = selectionMode.isActive;

        // Sync animation controllers with actual selection state (only once per build)
        if (isSelected &&
            _selectionController.value == 0.0 &&
            !_selectionController.isAnimating) {
          _selectionController.value = 1.0;
          _checkController.value = 1.0;
        }

        final child = SelectionListener(
          controller: selectionMode,
          index: widget.index,
          onSelectionChanged: (selected) {
            if (selected) {
              if (_kDefaultAnimationDuration != Duration.zero) {
                _scaleController.forward().then(
                  (value) => _scaleController.reverse(),
                );
              }
              _selectionController.forward();
              // Start check animation slightly after fill starts
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _checkController.forward();
              });
            } else {
              _selectionController.reverse();
              _checkController.reset();
            }
          },
          child: Stack(
            children: [
              widget.item,
              if (isInSelectionMode) ...[
                Positioned.fill(
                  child: ShadowGradientOverlay(
                    alignment: Alignment.topCenter,
                    colors: [
                      const Color.fromARGB(52, 0, 0, 0),
                      Colors.black12.withValues(alpha: 0),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildPreviewButton(context),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildCheckmark(isSelected, colorScheme),
                ),
              ],
            ],
          ),
        );

        // Skip scale animation if animations are disabled
        if (_kDefaultAnimationDuration == Duration.zero) {
          return child;
        }

        return AnimatedBuilder(
          animation: _scaleController,
          builder: (context, _) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildPreviewButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.zoom_in),
      onPressed: () {
        goToImagePreviewPage(
          context,
          widget.post,
          widget.config,
        );
      },
    );
  }

  Widget _buildCheckmark(bool isSelected, ColorScheme colorScheme) {
    final size = widget.indicatorSize ?? 32;

    return Container(
      margin: const EdgeInsets.all(4),
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _selectionAnimation,
          _checkAnimation,
        ]),
        builder: (context, _) => RepaintBoundary(
          child: IgnorePointer(
            child: CustomPaint(
              painter: SelectionIndicatorPainter(
                fillProgress: _selectionAnimation.value,
                checkProgress: _checkAnimation.value,
                isSelected: isSelected,
                primaryColor: colorScheme.primary,
                onPrimaryColor: colorScheme.onPrimary,
              ),
              size: Size.square(size),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectionIndicatorPainter extends CustomPainter {
  SelectionIndicatorPainter({
    required this.fillProgress,
    required this.checkProgress,
    required this.isSelected,
    required this.primaryColor,
    required this.onPrimaryColor,
  });

  final double fillProgress;
  final double checkProgress;
  final bool isSelected;
  final Color primaryColor;
  final Color onPrimaryColor;

  late final _borderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round;

  late final _fillPaint = Paint()..style = PaintingStyle.fill;

  late final _checkPaint = Paint()
    ..color = onPrimaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.min(size.width, size.height) / 2 - 2; // Account for border

    // Draw the filled circle background
    if (isSelected) {
      // Selected: filled with primary color
      _fillPaint.color = primaryColor.withValues(alpha: fillProgress);
    } else {
      // Unselected: black with low opacity
      _fillPaint.color = Colors.black.withValues(alpha: 0.2);
    }
    canvas.drawCircle(center, radius, _fillPaint);

    // Draw the white border only when not selected
    if (!isSelected) {
      canvas.drawCircle(center, radius, _borderPaint);
    }

    // Draw the checkmark if selected and has progress
    if (isSelected && checkProgress > 0) {
      _drawCheckmark(canvas, center, radius);
    }
  }

  void _drawCheckmark(Canvas canvas, Offset center, double radius) {
    // Scale checkmark based on available space - make it bigger
    final checkSize = radius * 0.8;

    // Create checkmark path with longer legs
    final path = Path();

    // Starting point (left side of check) - further left
    final startX = center.dx - checkSize * 0.5;
    final startY = center.dy;

    // Middle point (bottom of check) - lower
    final midX = center.dx - checkSize * 0.1;
    final midY = center.dy + checkSize * 0.4;

    // End point (right side of check) - further right and higher
    final endX = center.dx + checkSize * 0.5;
    final endY = center.dy - checkSize * 0.4;

    path
      ..moveTo(startX, startY)
      ..lineTo(midX, midY)
      ..lineTo(endX, endY);

    // Animate the path drawing - fade out on deselection instead of reverse
    final pathMetric = path.computeMetrics().first;
    final animatedPath = pathMetric.extractPath(
      0,
      pathMetric.length * checkProgress,
    );

    // Apply opacity based on overall selection progress for fade effect
    _checkPaint.color = onPrimaryColor.withValues(alpha: fillProgress);
    canvas.drawPath(animatedPath, _checkPaint);
  }

  @override
  bool shouldRepaint(SelectionIndicatorPainter oldDelegate) {
    return oldDelegate.fillProgress != fillProgress ||
        oldDelegate.checkProgress != checkProgress ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.onPrimaryColor != onPrimaryColor;
  }
}

class SelectionListener extends StatefulWidget {
  const SelectionListener({
    required this.controller,
    required this.index,
    required this.onSelectionChanged,
    required this.child,
    super.key,
  });

  final SelectionModeController controller;
  final int index;
  final void Function(bool selected) onSelectionChanged;
  final Widget child;

  @override
  State<SelectionListener> createState() => _SelectionListenerState();
}

class _SelectionListenerState extends State<SelectionListener> {
  late bool _previousSelected;

  @override
  void initState() {
    super.initState();
    _previousSelected = widget.controller.isSelected(widget.index);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final currentSelected = widget.controller.isSelected(widget.index);
    if (_previousSelected != currentSelected) {
      widget.onSelectionChanged(currentSelected);
      _previousSelected = currentSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
