// Project imports:
import 'package:boorusama/core/feats/notes/notes.dart';

abstract interface class NoteRepository {
  Future<List<Note>> getNotes(int postId);
}

class NoteRepositoryBuilder implements NoteRepository {
  const NoteRepositoryBuilder({
    required this.fetch,
  });

  final Future<List<Note>> Function(int postId) fetch;

  @override
  Future<List<Note>> getNotes(int postId) => fetch(postId);
}

class EmptyNoteRepository implements NoteRepository {
  const EmptyNoteRepository();

  @override
  Future<List<Note>> getNotes(int postId) async => [];
}
