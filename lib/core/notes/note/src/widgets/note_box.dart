// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../types/note_coordinate.dart';
import '../types/note_origin.dart';
import '../types/note_style.dart';

class NoteBox extends StatelessWidget {
  const NoteBox({
    super.key,
    required this.coordinate,
    required this.content,
    required this.inlineText,
    required this.style,
    required this.origin,
  });

  final NoteCoordinate coordinate;
  final String content;
  final bool inlineText;
  final NoteStyle? style;
  final NoteOrigin origin;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: origin == NoteOrigin.local
          ? _DashedBorderPainter(
              color: style?.borderColor ?? Colors.green,
            )
          : null,
      child: Container(
        width: coordinate.width,
        height: coordinate.height,
        decoration: BoxDecoration(
          color: inlineText
              ? Colors.white
              : origin == NoteOrigin.local
              ? (style?.backgroundColor ?? Colors.white54).withValues(
                  alpha: 0.7,
                )
              : style?.backgroundColor ?? Colors.white54,
          border: origin == NoteOrigin.server
              ? Border.fromBorderSide(
                  BorderSide(
                    color: style?.borderColor ?? Colors.red,
                  ),
                )
              : null,
        ),
        child: inlineText
            ? ClipRect(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    _stripHtml(content),
                    style: TextStyle(
                      fontSize: 8,
                      color: style?.foregroundColor ?? Colors.black,
                      backgroundColor: style?.backgroundColor ?? Colors.white,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
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

String _stripHtml(String html) {
  final exp = RegExp('<[^>]*>', multiLine: true);
  return html.replaceAll(exp, '').trim();
}
