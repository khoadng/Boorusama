// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../boorus/engine/providers.dart';
import '../configs/config.dart';
import '../configs/ref.dart';
import '../posts/post/post.dart';
import 'notes.dart';

final notesControllerProvider = NotifierProvider.autoDispose
    .family<NotesControllerNotifier, NotesControllerState, Post>(
      NotesControllerNotifier.new,
    );

final notesProvider =
    NotifierProvider.family<
      NotesNotifier,
      Map<int, IList<Note>>,
      BooruConfigAuth
    >(NotesNotifier.new);

final currentNotesProvider = Provider.autoDispose.family<IList<Note>?, Post>((
  ref,
  post,
) {
  final allNotes = ref.watch(notesProvider(ref.watchConfigAuth));

  return allNotes[post.id];
});

final emptyNoteRepoProvider = Provider<NoteRepository>(
  (_) => const EmptyNoteRepository(),
);

final noteRepoProvider = Provider.family<NoteRepository, BooruConfigAuth>(
  (ref, config) {
    final repo = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType);

    final noteRepo = repo?.note(config);

    if (noteRepo != null) {
      return noteRepo;
    }

    return ref.watch(emptyNoteRepoProvider);
  },
);

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
