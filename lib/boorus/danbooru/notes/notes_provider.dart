// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/notes/notes.dart';

final danbooruNoteRepoProvider =
    Provider.family<NoteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotes(
          postId: postId,
        )
        .then((value) => value.map((e) => e.toEntity()).toList()),
  );
});

extension NoteDtoX on NoteDto {
  Note toEntity() {
    final coord = NoteCoordinate(
      x: x?.toDouble() ?? 0,
      y: y?.toDouble() ?? 0,
      width: width?.toDouble() ?? 0,
      height: height?.toDouble() ?? 0,
    );

    return Note(
      coordinate: coord,
      content: body ?? '',
    );
  }
}
