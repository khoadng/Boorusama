// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../posts/post/post.dart';
import 'note_coordinate.dart';

class Note extends Equatable {
  const Note({
    required this.coordinate,
    required this.content,
  });

  const Note.empty() : coordinate = const NoteCoordinate.shrink(), content = '';

  final NoteCoordinate coordinate;
  final String content;

  Note copyWith({
    NoteCoordinate? coordinate,
    String? content,
  }) => Note(
    coordinate: coordinate ?? this.coordinate,
    content: content ?? this.content,
  );

  @override
  List<Object?> get props => [coordinate, content];
}

abstract interface class NoteRepository {
  Future<List<Note>> getNotes(int postId);
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
