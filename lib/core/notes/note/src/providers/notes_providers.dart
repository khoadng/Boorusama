// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../posts/post/types.dart';
import '../data/providers.dart';
import '../types/note.dart';

class NotesNotifier
    extends FamilyNotifier<Map<int, IList<Note>>, BooruConfigAuth> {
  @override
  Map<int, IList<Note>> build(BooruConfigAuth arg) {
    return {};
  }

  Future<void> load(Post post) async {
    final postId = post.id;

    if (!post.isTranslated) return;

    if (state.containsKey(postId)) return;

    final notes = state[postId];

    if (notes == null) {
      final noteRepo = ref.read(noteRepoProvider(arg));

      final notes = await noteRepo.getNotes(postId);

      state = {
        ...state,
        postId: notes.lock,
      };
    }
  }
}

final notesProvider =
    NotifierProvider.family<
      NotesNotifier,
      Map<int, IList<Note>>,
      BooruConfigAuth
    >(NotesNotifier.new);

final currentNotesProvider = Provider.autoDispose
    .family<IList<Note>?, (BooruConfigAuth, Post)>((ref, params) {
      final (auth, post) = params;
      final allNotes = ref.watch(notesProvider(auth));

      return allNotes[post.id];
    });
