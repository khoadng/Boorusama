// Flutter imports:
import 'package:flutter/painting.dart';

// Package imports:
import 'package:equatable/equatable.dart';

sealed class NoteCoordinate extends Equatable {
  const NoteCoordinate();

  NoteCoordinate withPercent(double widthPercent, double heightPercent);
  NoteQuadrant calculateQuadrant(double screenWidth, double screenHeight);
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
  NoteQuadrant calculateQuadrant(double screenWidth, double screenHeight) {
    final halfWidth = screenWidth / 2;
    final halfHeight = screenHeight / 2;

    if (x < halfWidth && y < halfHeight) {
      return NoteQuadrant.topLeft;
    } else if (x > halfWidth && y < halfHeight) {
      return NoteQuadrant.topRight;
    } else if (x < halfWidth && y > halfHeight) {
      return NoteQuadrant.bottomLeft;
    } else {
      return NoteQuadrant.bottomRight;
    }
  }

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
  NoteQuadrant calculateQuadrant(double screenWidth, double screenHeight) {
    if (points.isEmpty) return NoteQuadrant.topLeft;

    // Calculate centroid of polygon
    var centroidX = 0.0;
    var centroidY = 0.0;

    for (final point in points) {
      centroidX += point.dx;
      centroidY += point.dy;
    }

    centroidX /= points.length;
    centroidY /= points.length;

    final halfWidth = screenWidth / 2;
    final halfHeight = screenHeight / 2;

    if (centroidX < halfWidth && centroidY < halfHeight) {
      return NoteQuadrant.topLeft;
    } else if (centroidX > halfWidth && centroidY < halfHeight) {
      return NoteQuadrant.topRight;
    } else if (centroidX < halfWidth && centroidY > halfHeight) {
      return NoteQuadrant.bottomLeft;
    } else {
      return NoteQuadrant.bottomRight;
    }
  }

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

enum NoteQuadrant {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
