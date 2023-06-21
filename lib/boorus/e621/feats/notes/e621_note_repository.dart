// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'e621_note.dart';
import 'e621_note_dto.dart';

class E621NoteRepositoryApi implements NoteRepository {
  E621NoteRepositoryApi(this.api);

  final E621Api api;

  @override
  Future<List<Note>> getNotes(int postId) => api
      .getNotes(postId, 200)
      .then((value) => parseResponse(
            value: value,
            converter: (item) => E621NoteDto.fromJson(item),
          ))
      .then((value) => value.map(e621NoteDtoToE621Note).toList())
      .then((value) => value.map(e621NoteToNote).toList())
      .catchError((_) => <Note>[]);
}

E621Note e621NoteDtoToE621Note(E621NoteDto dto) {
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
    coordinate: NoteCoordinate(
      x: e621Note.x.toDouble(),
      y: e621Note.y.toDouble(),
      height: e621Note.height.toDouble(),
      width: e621Note.width.toDouble(),
    ),
    content: e621Note.body,
  );
}
