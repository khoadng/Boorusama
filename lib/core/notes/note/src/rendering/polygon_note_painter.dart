// Flutter imports:
import 'package:flutter/material.dart';

class PolygonNotePainter extends CustomPainter {
  PolygonNotePainter({
    required this.points,
    required this.borderColor,
    required this.backgroundColor,
  });

  final List<Offset> points;
  final Color borderColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path()..addPolygon(points, true);

    // Draw filled polygon
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(PolygonNotePainter oldDelegate) =>
      points != oldDelegate.points ||
      borderColor != oldDelegate.borderColor ||
      backgroundColor != oldDelegate.backgroundColor;
}
