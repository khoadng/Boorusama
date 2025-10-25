// Flutter imports:
import 'package:flutter/painting.dart';

// Package imports:
import 'package:equatable/equatable.dart';

sealed class NoteCoordinate extends Equatable {
  const NoteCoordinate();

  NoteCoordinate withPercent(double widthPercent, double heightPercent);
  EdgeInsetsGeometry getMargin();
  Size getSize();
}

class RectangleNoteCoordinate extends NoteCoordinate {
  const RectangleNoteCoordinate({
    required this.x,
    required this.y,
    required this.height,
    required this.width,
  });

  const RectangleNoteCoordinate.shrink() : x = 0, y = 0, height = 0, width = 0;

  final double x;
  final double y;
  final double height;
  final double width;

  @override
  NoteCoordinate withPercent(double widthPercent, double heightPercent) =>
      RectangleNoteCoordinate(
        x: x * widthPercent,
        y: y * heightPercent,
        height: height * heightPercent,
        width: width * widthPercent,
      );

  @override
  EdgeInsetsGeometry getMargin() => EdgeInsets.only(left: x, top: y);

  @override
  Size getSize() => Size(width, height);

  @override
  List<Object?> get props => [x, y, width, height];
}

class PolygonNoteCoordinate extends NoteCoordinate {
  const PolygonNoteCoordinate({
    required this.points,
  });

  const PolygonNoteCoordinate.empty() : points = const [];

  final List<Offset> points;

  /// Returns points relative to the bounding box origin (0,0)
  List<Offset> getRelativePoints() {
    if (points.isEmpty) return [];

    final minX = points.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);

    return points.map((p) => Offset(p.dx - minX, p.dy - minY)).toList();
  }

  @override
  NoteCoordinate withPercent(double widthPercent, double heightPercent) =>
      PolygonNoteCoordinate(
        points: points
            .map((p) => Offset(p.dx * widthPercent, p.dy * heightPercent))
            .toList(),
      );

  @override
  EdgeInsetsGeometry getMargin() {
    if (points.isEmpty) return EdgeInsets.zero;

    final minX = points.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);

    return EdgeInsets.only(left: minX, top: minY);
  }

  @override
  Size getSize() {
    if (points.isEmpty) return Size.zero;

    var minX = points.first.dx;
    var maxX = points.first.dx;
    var minY = points.first.dy;
    var maxY = points.first.dy;

    for (final point in points.skip(1)) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Size(maxX - minX, maxY - minY);
  }

  @override
  List<Object?> get props => [points];
}
