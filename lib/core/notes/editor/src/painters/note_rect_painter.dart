// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../types/note_image.dart';
import '../types/note_rect.dart';

class NoteRectPainter extends CustomPainter {
  NoteRectPainter({
    required this.savedRects,
    required this.image,
    this.movingRectIndex,
    this.selectedRectIndex,
    this.drawingRect,
  });

  final List<NoteRect> savedRects;
  final NoteImage image;
  final int? movingRectIndex;
  final int? selectedRectIndex;
  final NoteRect? drawingRect;

  /// Convert image coordinates to widget coordinates for rendering
  Offset _toWidgetCoordinates(Offset imagePosition, Size widgetSize) {
    final scaleX = widgetSize.width / image.width;
    final scaleY = widgetSize.height / image.height;
    return Offset(
      imagePosition.dx * scaleX,
      imagePosition.dy * scaleY,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final savedPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final selectedPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final movingPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final drawingPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw saved squares (skip the one being moved)
    for (var i = 0; i < savedRects.length; i++) {
      if (i == movingRectIndex) continue;

      final square = savedRects[i];
      // Convert from image coordinates to widget coordinates
      final widgetStart = _toWidgetCoordinates(square.start, size);
      final widgetEnd = _toWidgetCoordinates(square.end, size);
      final rect = Rect.fromPoints(widgetStart, widgetEnd);
      canvas.drawRect(rect, fillPaint);

      // Use selected paint if this rect is selected
      if (i == selectedRectIndex) {
        canvas.drawRect(rect, selectedPaint);
      } else {
        canvas.drawRect(rect, savedPaint);
      }
    }

    // Draw the moving square in green
    if (movingRectIndex != null && movingRectIndex! < savedRects.length) {
      final square = savedRects[movingRectIndex!];
      final widgetStart = _toWidgetCoordinates(square.start, size);
      final widgetEnd = _toWidgetCoordinates(square.end, size);
      final rect = Rect.fromPoints(widgetStart, widgetEnd);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, movingPaint);
    }

    // Draw the square being drawn in red
    if (drawingRect != null) {
      final widgetStart = _toWidgetCoordinates(drawingRect!.start, size);
      final widgetEnd = _toWidgetCoordinates(drawingRect!.end, size);
      final rect = Rect.fromPoints(widgetStart, widgetEnd);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, drawingPaint);
    }
  }

  @override
  bool shouldRepaint(NoteRectPainter oldDelegate) => true;
}
