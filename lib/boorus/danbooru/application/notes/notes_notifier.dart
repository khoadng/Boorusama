// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'notes_provider.dart';

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
