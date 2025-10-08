// Package imports:
import 'package:equatable/equatable.dart';

class NoteCoordinate extends Equatable {
  const NoteCoordinate({
    required this.x,
    required this.y,
    required this.height,
    required this.width,
  });

  const NoteCoordinate.shrink() : x = 0, y = 0, height = 0, width = 0;

  final double x;
  final double y;
  final double height;
  final double width;

  NoteCoordinate withPercent(double widthPercent, double heightPercent) =>
      NoteCoordinate(
        x: x * widthPercent,
        y: y * heightPercent,
        height: height * heightPercent,
        width: width * widthPercent,
      );

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
  List<Object?> get props => [x, y, width, height];
}

enum NoteQuadrant {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
