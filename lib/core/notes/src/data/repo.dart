// Project imports:
import '../types/note.dart';

class EmptyNoteRepository implements NoteRepository {
  const EmptyNoteRepository();

  @override
  Future<List<Note>> getNotes(int postId) async => [];
}

class NoteRepositoryBuilder implements NoteRepository {
  const NoteRepositoryBuilder({
    required this.fetch,
  });

  final Future<List<Note>> Function(int postId) fetch;

  @override
  Future<List<Note>> getNotes(int postId) => fetch(postId);
}
