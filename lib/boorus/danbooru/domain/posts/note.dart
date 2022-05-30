// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'note_coordinate.dart';

class Note {
  final NoteCoordinate coordinate;
  final String content;

  Note({
    required this.coordinate,
    required this.content,
  });
}
