// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../posts/post/post.dart';
import 'note_coordinate.dart';
import 'note_origin.dart';

class Note extends Equatable {
  const Note({
    required this.coordinate,
    required this.content,
    this.origin = NoteOrigin.server,
  });

  const Note.empty()
    : coordinate = const NoteCoordinate.shrink(),
      content = '',
      origin = NoteOrigin.server;

  final NoteCoordinate coordinate;
  final String content;
  final NoteOrigin origin;

  Note copyWith({
    NoteCoordinate? coordinate,
    String? content,
    NoteOrigin? origin,
  }) => Note(
    coordinate: coordinate ?? this.coordinate,
    content: content ?? this.content,
    origin: origin ?? this.origin,
  );

  @override
  List<Object?> get props => [coordinate, content, origin];
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
