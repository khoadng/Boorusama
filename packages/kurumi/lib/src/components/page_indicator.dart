import 'package:material_ui/material_ui.dart';

typedef KurumiPageIndicatorTapCallback = void Function(int index);

class KurumiPageIndicator extends StatelessWidget {
  const KurumiPageIndicator({
    required this.controller,
    required this.count,
    super.key,
    this.onDotClicked,
    this.activeColor,
    this.inactiveColor,
    this.dotWidth = 16,
    this.dotHeight = 16,
    this.spacing = 8,
    this.radius = 16,
  }) : assert(count > 0),
       assert(dotWidth > 0),
       assert(dotHeight > 0),
       assert(spacing >= 0),
       assert(radius >= 0);

  final PageController controller;
  final int count;
  final KurumiPageIndicatorTapCallback? onDotClicked;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotWidth;
  final double dotHeight;
  final double spacing;
  final double radius;

  double get _width => dotWidth * count + spacing * (count - 1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textDirection = Directionality.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = _pageOffset();

        return Semantics(
          value: '${offset.round() + 1}/$count',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onDotClicked == null
                ? null
                : (details) => _handleTap(
                    details.localPosition.dx,
                    offset,
                    textDirection,
                  ),
            child: CustomPaint(
              size: Size(_width, dotHeight),
              painter: _KurumiWormIndicatorPainter(
                count: count,
                offset: offset,
                activeColor: activeColor ?? colorScheme.primary,
                inactiveColor:
                    inactiveColor ??
                    colorScheme.outlineVariant.withValues(alpha: 0.25),
                dotWidth: dotWidth,
                dotHeight: dotHeight,
                spacing: spacing,
                radius: radius,
                textDirection: textDirection,
              ),
            ),
          ),
        );
      },
    );
  }

  double _pageOffset() {
    try {
      final page = controller.page;
      if (page != null && page.isFinite) {
        return page.clamp(0, count - 1).toDouble();
      }
    } on AssertionError {
      // A PageController has no page until it is attached to a PageView.
    }

    return controller.initialPage.clamp(0, count - 1).toDouble();
  }

  void _handleTap(
    double physicalOffset,
    double currentOffset,
    TextDirection textDirection,
  ) {
    final logicalOffset = textDirection == TextDirection.rtl
        ? _width - physicalOffset
        : physicalOffset;
    final index = ((logicalOffset + spacing / 2) / (dotWidth + spacing))
        .floor()
        .clamp(0, count - 1);

    if (index != currentOffset.floor()) onDotClicked?.call(index);
  }
}

class _KurumiWormIndicatorPainter extends CustomPainter {
  const _KurumiWormIndicatorPainter({
    required this.count,
    required this.offset,
    required this.activeColor,
    required this.inactiveColor,
    required this.dotWidth,
    required this.dotHeight,
    required this.spacing,
    required this.radius,
    required this.textDirection,
  });

  final int count;
  final double offset;
  final Color activeColor;
  final Color inactiveColor;
  final double dotWidth;
  final double dotHeight;
  final double spacing;
  final double radius;
  final TextDirection textDirection;

  double get _distance => dotWidth + spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final inactivePaint = Paint()..color = inactiveColor;
    for (var index = 0; index < count; index++) {
      canvas.drawRRect(
        _physicalRect(
          size,
          Rect.fromLTWH(index * _distance, 0, dotWidth, dotHeight),
        ),
        inactivePaint,
      );
    }

    final page = offset.clamp(0, count - 1).toDouble();
    final pageIndex = page.floor();
    final transition = (page - pageIndex) * 2;
    final start = pageIndex * _distance;
    var head = start;
    var tail = start + dotWidth + transition * _distance;

    if (transition > 1) {
      tail = start + dotWidth + _distance;
      head = start + _distance * (transition - 1);
    }

    canvas.drawRRect(
      _physicalRect(
        size,
        Rect.fromLTRB(head, 0, tail, dotHeight),
      ),
      Paint()..color = activeColor,
    );
  }

  RRect _physicalRect(Size size, Rect logicalRect) {
    final rect = textDirection == TextDirection.rtl
        ? Rect.fromLTRB(
            size.width - logicalRect.right,
            logicalRect.top,
            size.width - logicalRect.left,
            logicalRect.bottom,
          )
        : logicalRect;

    return RRect.fromRectAndRadius(rect, Radius.circular(radius));
  }

  @override
  bool shouldRepaint(_KurumiWormIndicatorPainter oldDelegate) =>
      count != oldDelegate.count ||
      offset != oldDelegate.offset ||
      activeColor != oldDelegate.activeColor ||
      inactiveColor != oldDelegate.inactiveColor ||
      dotWidth != oldDelegate.dotWidth ||
      dotHeight != oldDelegate.dotHeight ||
      spacing != oldDelegate.spacing ||
      radius != oldDelegate.radius ||
      textDirection != oldDelegate.textDirection;
}
