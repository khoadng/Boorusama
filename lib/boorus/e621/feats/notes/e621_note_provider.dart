// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/clients/e621/types/types.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'e621_note.dart';

final e621NoteRepoProvider = Provider<NoteRepository>((ref) {
  final client = ref.watch(e621ClientProvider);

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotes(postId: postId)
        .then((value) => value.map(e621NoteDtoToE621Note).toList())
        .then((value) => value.map(e621NoteToNote).toList())
        .catchError((_) => <Note>[]),
  );
});

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
