import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'shadow_gradient_overlay.dart';

const _kurumiSelectableItemAnimationDuration = Duration(milliseconds: 200);

class KurumiSelectableItem extends StatefulWidget {
  const KurumiSelectableItem({
    required this.item,
    required this.onPreview,
    required this.isInSelectionMode,
    required this.isSelected,
    super.key,
    this.indicatorSize,
  });

  final Widget item;
  final VoidCallback onPreview;
  final bool isInSelectionMode;
  final bool isSelected;
  final double? indicatorSize;

  @override
  State<KurumiSelectableItem> createState() => _KurumiSelectableItemState();
}

class _KurumiSelectableItemState extends State<KurumiSelectableItem>
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
      milliseconds:
          (_kurumiSelectableItemAnimationDuration.inMilliseconds * 0.4).round(),
    );
  }

  @override
  void didUpdateWidget(covariant KurumiSelectableItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      _handleSelectionChanged(widget.isSelected);
    }
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
    final isSelected = widget.isSelected;
    final isInSelectionMode = widget.isInSelectionMode;

    if (isSelected &&
        _selectionController.value == 0.0 &&
        !_selectionController.isAnimating) {
      _selectionController.value = 1.0;
      _checkController.value = 1.0;
    }

    final child = Stack(
      children: [
        widget.item,
        if (isInSelectionMode) ...[
          Positioned.fill(
            child: KurumiShadowGradientOverlay(
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
            child: _buildPreviewButton(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildCheckmark(isSelected, colorScheme),
          ),
        ],
      ],
    );

    final semanticChild = Semantics(
      container: isInSelectionMode,
      selected: isInSelectionMode ? isSelected : null,
      child: child,
    );

    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, _) => Transform.scale(
        scale: _scaleAnimation.value,
        child: semanticChild,
      ),
    );
  }

  void _handleSelectionChanged(bool selected) {
    if (selected) {
      if (_kurumiSelectableItemAnimationDuration != Duration.zero) {
        _scaleController.forward().then(
          (value) => _scaleController.reverse(),
        );
      }
      _selectionController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _checkController.forward();
      });
    } else {
      _selectionController.reverse();
      _checkController.reset();
    }
  }

  Widget _buildPreviewButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.zoom_in),
      onPressed: widget.onPreview,
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
              painter: _KurumiSelectionIndicatorPainter(
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

class _KurumiSelectionIndicatorPainter extends CustomPainter {
  _KurumiSelectionIndicatorPainter({
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
    final radius = math.min(size.width, size.height) / 2 - 2;

    if (isSelected) {
      _fillPaint.color = primaryColor.withValues(alpha: fillProgress);
    } else {
      _fillPaint.color = Colors.black.withValues(alpha: 0.2);
    }
    canvas.drawCircle(center, radius, _fillPaint);

    if (!isSelected) {
      canvas.drawCircle(center, radius, _borderPaint);
    }

    if (isSelected && checkProgress > 0) {
      _drawCheckmark(canvas, center, radius);
    }
  }

  void _drawCheckmark(Canvas canvas, Offset center, double radius) {
    final checkSize = radius * 0.8;
    final startX = center.dx - checkSize * 0.5;
    final startY = center.dy;
    final midX = center.dx - checkSize * 0.1;
    final midY = center.dy + checkSize * 0.4;
    final endX = center.dx + checkSize * 0.5;
    final endY = center.dy - checkSize * 0.4;
    final path = Path()
      ..moveTo(startX, startY)
      ..lineTo(midX, midY)
      ..lineTo(endX, endY);

    final pathMetric = path.computeMetrics().first;
    final animatedPath = pathMetric.extractPath(
      0,
      pathMetric.length * checkProgress,
    );

    _checkPaint.color = onPrimaryColor.withValues(alpha: fillProgress);
    canvas.drawPath(animatedPath, _checkPaint);
  }

  @override
  bool shouldRepaint(_KurumiSelectionIndicatorPainter oldDelegate) {
    return oldDelegate.fillProgress != fillProgress ||
        oldDelegate.checkProgress != checkProgress ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.onPrimaryColor != onPrimaryColor;
  }
}
