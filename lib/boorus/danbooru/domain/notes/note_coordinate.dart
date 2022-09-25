// Package imports:
import 'package:equatable/equatable.dart';

class NoteCoordinate extends Equatable {
  const NoteCoordinate({
    required this.x,
    required this.y,
    required this.height,
    required this.width,
  });

  final double x;
  final double y;
  final double height;
  final double width;

  NoteCoordinate calibrate(
    double screenHeight,
    double screenWidth,
    double screenAspectRatio,
    double postHeight,
    double postWidth,
    double postAspectRatio,
  ) {
    var aspectRatio = 1.0;
    double offset = 0;
    double newX;
    double newY;
    double newWidth;
    double newHeight;

    if (screenHeight > screenWidth) {
      if (screenAspectRatio < postAspectRatio) {
        aspectRatio = screenWidth / postWidth;
        offset = (screenHeight - aspectRatio * postHeight) / 2;
        newX = x * aspectRatio;
        newY = y * aspectRatio + offset;
      } else {
        aspectRatio = screenHeight / postHeight;
        offset = (screenWidth - aspectRatio * postWidth) / 2;
        newX = x * aspectRatio + offset;
        newY = y * aspectRatio;
      }
    } else {
      if (screenAspectRatio > postAspectRatio) {
        aspectRatio = screenHeight / postHeight;
        offset = (screenWidth - aspectRatio * postWidth) / 2;
        newX = x * aspectRatio + offset;
        newY = y * aspectRatio;
      } else {
        aspectRatio = screenWidth / postWidth;
        offset = (screenHeight - aspectRatio * postHeight) / 2;
        newX = x * aspectRatio;
        newY = y * aspectRatio + offset;
      }
    }

    newWidth = width * aspectRatio;
    newHeight = height * aspectRatio;

    return NoteCoordinate(
      x: newX,
      y: newY,
      width: newWidth,
      height: newHeight,
    );
  }

  @override
  List<Object?> get props => [x, y, width, height];
}
