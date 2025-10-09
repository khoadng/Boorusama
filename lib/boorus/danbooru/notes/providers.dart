// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/notes/editor/types.dart';
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

final danbooruInitialNotesProvider = FutureProvider.autoDispose
    .family<List<NoteRectData>, int>((ref, postId) async {
      final auth = ref.watchConfigAuth;
      final client = ref.watch(danbooruClientProvider(auth));

      final notes = await client.getNotes(postId: postId);
      return notes
          .where((note) => note.isActive ?? false)
          .map(
            (dto) => NoteRectData(
              id: dto.id,
              x: dto.x ?? 0,
              y: dto.y ?? 0,
              width: dto.width ?? 0,
              height: dto.height ?? 0,
              body: dto.body ?? '',
            ),
          )
          .toList();
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
