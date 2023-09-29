// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/feats/notes/notes.dart';

const _notesLimit = 200;

final danbooruNoteRepoProvider = Provider<NoteRepository>((ref) {
  final client = ref.watch(danbooruClientProvider);

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotes(
          postId: postId,
          limit: _notesLimit,
        )
        .then((value) => value.map((e) => e.toEntity()).toList()),
  );
});

extension NoteDtoX on NoteDto {
  Note toEntity() {
    final coord = NoteCoordinate(
      x: x.toDouble(),
      y: y.toDouble(),
      width: width.toDouble(),
      height: height.toDouble(),
    );

    return Note(
      coordinate: coord,
      content: body,
    );
  }
}
