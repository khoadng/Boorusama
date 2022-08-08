// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'note_coordinate.dart';

class Note extends Equatable {
  const Note({
    required this.coordinate,
    required this.content,
  });

  final NoteCoordinate coordinate;
  final String content;

  @override
  List<Object?> get props => [coordinate, content];
}
