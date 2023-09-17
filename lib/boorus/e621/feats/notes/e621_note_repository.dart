// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/clients/e621/types/types.dart';
import 'e621_note.dart';

class E621NoteRepositoryApi implements NoteRepository {
  E621NoteRepositoryApi(
    this.client,
  );

  final E621Client client;

  @override
  Future<List<Note>> getNotes(int postId) => client
      .getNotes(postId: postId)
      .then((value) => value.map(e621NoteDtoToE621Note).toList())
      .then((value) => value.map(e621NoteToNote).toList())
      .catchError((_) => <Note>[]);
}

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
    coordinate: NoteCoordinate(
      x: e621Note.x.toDouble(),
      y: e621Note.y.toDouble(),
      height: e621Note.height.toDouble(),
      width: e621Note.width.toDouble(),
    ),
    content: e621Note.body,
  );
}
