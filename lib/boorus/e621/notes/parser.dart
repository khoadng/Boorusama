// Package imports:
import 'package:booru_clients/e621.dart';

// Project imports:
import '../../../core/notes/note/types.dart';
import 'types.dart';

E621Note e621NoteDtoToE621Note(NoteDto dto) {
  return E621Note(
    x: dto.x ?? 0,
    y: dto.y ?? 0,
    width: dto.width ?? 0,
    height: dto.height ?? 0,
    body: dto.body ?? '',
  );
}

Note e621NoteToNote(E621Note e621Note) {
  return Note(
    coordinate: RectangleNoteCoordinate(
      x: e621Note.x.toDouble(),
      y: e621Note.y.toDouble(),
      height: e621Note.height.toDouble(),
      width: e621Note.width.toDouble(),
    ),
    content: e621Note.body,
  );
}
