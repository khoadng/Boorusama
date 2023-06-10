// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';

class NotesNotifier extends AutoDisposeFamilyNotifier<List<Note>, Post> {
  @override
  List<Note> build(Post arg) {
    return [];
  }

  Future<void> load() async {
    if (state.isEmpty && arg.isTranslated) {
      final notes =
          await ref.read(danbooruNoteRepoProvider).getNotesFrom(arg.id);
      state = notes;
    }
  }
}
