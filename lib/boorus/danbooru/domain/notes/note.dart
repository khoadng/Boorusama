// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'note_coordinate.dart';

class Note extends Equatable {
  const Note({
    required this.coordinate,
    required this.content,
  });

  factory Note.empty() => Note(
        coordinate: NoteCoordinate.shrink(),
        content: '',
      );

  final NoteCoordinate coordinate;
  final String content;

  @override
  List<Object?> get props => [coordinate, content];
}

extension NoteX on Note {
  Note copyWith({
    NoteCoordinate? coordinate,
    String? content,
  }) =>
      Note(
        coordinate: coordinate ?? this.coordinate,
        content: content ?? this.content,
      );
}
