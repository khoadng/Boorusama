// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/notes/note/providers.dart';
import '../../../core/notes/note/types.dart';
import '../client_provider.dart';

final danbooruNoteRepoProvider =
    Provider.family<NoteRepository, BooruConfigAuth>((ref, config) {
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
    final coord = RectangleNoteCoordinate(
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
