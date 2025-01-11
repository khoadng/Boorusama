// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:path_drawing/path_drawing.dart';

class DottedBorder extends StatelessWidget {
  DottedBorder({
    required this.child,
    super.key,
    this.color = Colors.black,
    this.gradient,
    this.strokeWidth = 1,
    this.borderType = BorderType.rect,
    this.dashPattern = const [3, 1],
    this.padding = const EdgeInsets.all(2),
    this.borderPadding = EdgeInsets.zero,
    this.radius = Radius.zero,
    this.strokeCap = StrokeCap.butt,
    this.customPath,
    this.stackFit = StackFit.loose,
  }) {
    assert(_isValidDashPattern(dashPattern), 'Invalid dash pattern');
  }

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets borderPadding;
  final double strokeWidth;
  final Color color;
  final Gradient? gradient;
  final List<double> dashPattern;
  final BorderType borderType;
  final Radius radius;
  final StrokeCap strokeCap;
  final PathBuilder? customPath;
  final StackFit stackFit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: stackFit,
      children: <Widget>[
        Padding(
          padding: padding,
          child: child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: DashedPainter(
                padding: borderPadding,
                strokeWidth: strokeWidth,
                radius: radius,
                color: color,
                gradient: gradient,
                borderType: borderType,
                dashPattern: dashPattern,
                customPath: customPath,
                strokeCap: strokeCap,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Compute if [dashPattern] is valid. The following conditions need to be met
  /// * Cannot be null or empty
  /// * If [dashPattern] has only 1 element, it cannot be 0
  bool _isValidDashPattern(List<double>? dashPattern) {
    final dashSet = dashPattern?.toSet();
    if (dashSet == null) return false;
    if (dashSet.length == 1 && dashSet.elementAt(0) == 0.0) return false;
    if (dashSet.isEmpty) return false;
    return true;
  }
}

/// The different supported BorderTypes
enum BorderType { circle, rrect, rect, oval }

typedef PathBuilder = Path Function(Size);

class DashedPainter extends CustomPainter {
  DashedPainter({
    this.strokeWidth = 2,
    this.dashPattern = const <double>[3, 1],
    this.color = Colors.black,
    this.gradient,
    this.borderType = BorderType.rect,
    this.radius = Radius.zero,
    this.strokeCap = StrokeCap.butt,
    this.customPath,
    this.padding = EdgeInsets.zero,
  }) : assert(dashPattern.isNotEmpty, 'Dash Pattern cannot be empty');

  final double strokeWidth;
  final List<double> dashPattern;
  final Color color;
  final Gradient? gradient;
  final BorderType borderType;
  final Radius radius;
  final StrokeCap strokeCap;
  final PathBuilder? customPath;
  final EdgeInsets padding;

  @override
  void paint(Canvas canvas, Size size) {
    Size sz;
    if (padding == EdgeInsets.zero) {
      sz = size;
    } else {
      canvas.translate(padding.left, padding.top);
      sz = Size(
        size.width - padding.horizontal,
        size.height - padding.vertical,
      );
    }

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    if (gradient != null) {
      final rect = Offset.zero & sz;
      paint.shader = gradient!.createShader(rect);
    } else {
      paint.color = color;
    }

    final path = customPath != null
        ? dashPath(
            customPath!(sz),
            dashArray: CircularIntervalList(dashPattern),
          )
        : _getPath(sz);

    canvas.drawPath(path, paint);
  }

  /// Returns a [Path] based on the the [borderType] parameter
  Path _getPath(Size size) => dashPath(
        switch (borderType) {
          BorderType.circle => _getCirclePath(size),
          BorderType.rrect => _getRRectPath(size, radius),
          BorderType.rect => _getRectPath(size),
          BorderType.oval => _getOvalPath(size)
        },
        dashArray: CircularIntervalList(dashPattern),
      );

  /// Returns a circular path of [size]
  Path _getCirclePath(Size size) {
    final w = size.width;
    final h = size.height;
    final s = size.shortestSide;

    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w > s ? (w - s) / 2 : 0,
            h > s ? (h - s) / 2 : 0,
            s,
            s,
          ),
          Radius.circular(s / 2),
        ),
      );
  }

  /// Returns a Rounded Rectangular Path with [radius] of [size]
  Path _getRRectPath(Size size, Radius radius) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height,
          ),
          radius,
        ),
      );
  }

  /// Returns a path of [size]
  Path _getRectPath(Size size) {
    return Path()
      ..addRect(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );
  }

  /// Return an oval path of [size]
  Path _getOvalPath(Size size) {
    return Path()
      ..addOval(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );
  }

  @override
  bool shouldRepaint(DashedPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.dashPattern != dashPattern ||
        oldDelegate.padding != padding ||
        oldDelegate.borderType != borderType;
  }
}

class DottedBorderButton extends StatelessWidget {
  const DottedBorderButton({
    required this.title,
    super.key,
    this.onTap,
    this.borderColor,
  });

  final void Function()? onTap;
  final String title;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: DottedBorder(
          color: borderColor ?? Theme.of(context).colorScheme.outline,
          radius: const Radius.circular(12),
          dashPattern: const [12, 6],
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
