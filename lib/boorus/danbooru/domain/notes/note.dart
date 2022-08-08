// Project imports:
import 'note_coordinate.dart';

class Note {

  Note({
    required this.coordinate,
    required this.content,
  });
  final NoteCoordinate coordinate;
  final String content;
}
