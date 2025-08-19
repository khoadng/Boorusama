// Flutter imports:
import 'package:flutter/material.dart';

enum InfoCircleStyle { solid, outline }

class InfoCircleIcon extends StatelessWidget {
  const InfoCircleIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.style = InfoCircleStyle.outline,
  });

  final double size;
  final Color? color;
  final InfoCircleStyle style;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).iconTheme.color ?? Colors.black;

    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: InfoCirclePainter(
          color: effectiveColor,
          style: style,
        ),
      ),
    );
  }
}

class InfoCirclePainter extends CustomPainter {
  InfoCirclePainter({
    required this.color,
    required this.style,
  });

  final Color color;
  final InfoCircleStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (style == InfoCircleStyle.solid) {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);

      final contrastPaint = Paint()
        ..color = _getContrastingColor(color)
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round;

      _drawInfoSymbol(canvas, size, contrastPaint);
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.06;
      canvas.drawCircle(center, radius - paint.strokeWidth / 2, paint);

      _drawInfoSymbol(canvas, size, paint);
    }
  }

  void _drawInfoSymbol(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final symbolSize = size.width * 0.75;

    final dotRadius = symbolSize * 0.07;
    final dotCenter = Offset(center.dx, center.dy - symbolSize * 0.28);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, dotRadius, paint);

    final lineWidth = symbolSize * 0.11;
    final stemStart = Offset(center.dx, center.dy - symbolSize * 0.1);
    final stemEnd = Offset(center.dx, center.dy + symbolSize * 0.25);

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(stemStart, stemEnd, paint);

    final serifWidth = symbolSize * 0.25;
    final serifStart = Offset(center.dx - serifWidth / 2, stemEnd.dy);
    final serifEnd = Offset(center.dx + serifWidth / 2, stemEnd.dy);
    canvas.drawLine(serifStart, serifEnd, paint);

    final peakWidth = symbolSize * 0.12;
    final peakStart = Offset(center.dx - peakWidth, stemStart.dy);
    final peakEnd = Offset(center.dx, stemStart.dy);
    canvas.drawLine(peakStart, peakEnd, paint);
  }

  Color _getContrastingColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(InfoCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.style != style;
  }
}
