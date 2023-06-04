// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/posts/posts.dart';
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
    final widthPercent = widthConstraint / post.width;
    final heightPercent = heightConstraint / post.height;

    return copyWith(
      coordinate: coordinate.withPercent(widthPercent, heightPercent),
    );
  }
}
