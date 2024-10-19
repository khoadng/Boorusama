// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'note.dart';

class NoteCoordinate extends Equatable {
  const NoteCoordinate({
    required this.x,
    required this.y,
    required this.height,
    required this.width,
  });

  factory NoteCoordinate.shrink() => const NoteCoordinate(
        x: 0,
        y: 0,
        height: 0,
        width: 0,
      );

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

  @override
  List<Object?> get props => [x, y, width, height];
}

extension NoteCoordX on Note {
  Note adjustNoteCoordFor(
    Post post, {
    required double widthConstraint,
    required double heightConstraint,
  }) {
    if (post.width == 0 || post.height == 0) {
      return this;
    }

    final widthPercent = widthConstraint / post.width;
    final heightPercent = heightConstraint / post.height;

    return copyWith(
      coordinate: coordinate.withPercent(widthPercent, heightPercent),
    );
  }
}

enum NoteQuadrant {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

extension NoteCoordinateQuadrant on NoteCoordinate {
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
}
