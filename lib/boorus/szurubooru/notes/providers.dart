// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/notes/note/providers.dart';
import '../../../core/notes/note/types.dart';
import '../client_provider.dart';
import 'parser.dart';

final szurubooruNoteRepoProvider =
    Provider.family<NoteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(szurubooruClientProvider(config));

      return NoteRepositoryBuilder(
        fetch: (postId) async {
          try {
            final post = await client.getPost(postId);

            return switch (post) {
              null => <Note>[],
              _ => _parseNotes(post),
            };
          } catch (_) {
            return <Note>[];
          }
        },
      );
    });

List<Note> _parseNotes(PostDto post) {
  final notes = post.notes;
  if (notes == null || notes.isEmpty) return <Note>[];

  final imageWidth = post.canvasWidth?.toDouble() ?? 1.0;
  final imageHeight = post.canvasHeight?.toDouble() ?? 1.0;

  return notes
      .map(
        (note) => szurubooruNoteToNote(
          note,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
      )
      .toList();
}
