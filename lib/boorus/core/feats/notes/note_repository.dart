// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';

abstract interface class NoteRepository {
  Future<List<Note>> getNotes(int postId);
}

class EmptyNoteRepository implements NoteRepository {
  const EmptyNoteRepository();

  @override
  Future<List<Note>> getNotes(int postId) async => [];
}
