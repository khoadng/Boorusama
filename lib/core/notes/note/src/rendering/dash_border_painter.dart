// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/widgets.dart';

class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
  });

  final Color color;
  static const strokeWidth = 4.0;
  static const dashWidth = 4.0;
  static const dashSpace = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw top border
    _drawDashedLine(
      canvas,
      paint,
      Offset.zero,
      Offset(size.width, 0),
    );

    // Draw right border
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, 0),
      Offset(size.width, size.height),
    );

    // Draw bottom border
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, size.height),
      Offset(0, size.height),
    );

    // Draw left border
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, size.height),
      Offset.zero,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    final unitDx = dx / distance;
    final unitDy = dy / distance;

    for (var i = 0; i < dashCount; i++) {
      final startDash = Offset(
        start.dx + unitDx * (dashWidth + dashSpace) * i,
        start.dy + unitDy * (dashWidth + dashSpace) * i,
      );
      final endDash = Offset(
        start.dx + unitDx * ((dashWidth + dashSpace) * i + dashWidth),
        start.dy + unitDy * ((dashWidth + dashSpace) * i + dashWidth),
      );
      canvas.drawLine(startDash, endDash, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
