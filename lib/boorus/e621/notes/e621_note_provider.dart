// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/notes/notes.dart';
import '../e621.dart';
import 'e621_note.dart';

final e621NoteRepoProvider =
    Provider.family<NoteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(e621ClientProvider(config));

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
