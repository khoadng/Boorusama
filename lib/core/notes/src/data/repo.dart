// Project imports:
import '../types/note.dart';

class EmptyNoteRepository implements NoteRepository {
  const EmptyNoteRepository();

  @override
  Future<List<Note>> getNotes(int postId) async => [];

  @override
  Future<Note?> createNote(int postId, Note note) async => null;
}

class NoteRepositoryBuilder implements NoteRepository {
  const NoteRepositoryBuilder({
    required this.fetch,
    this.create,
  });

  final Future<List<Note>> Function(int postId) fetch;
  final Future<Note> Function(int postId, Note note)? create;

  @override
  Future<List<Note>> getNotes(int postId) => fetch(postId);

  @override
  Future<Note?> createNote(int postId, Note note) => switch (create) {
    null => Future.sync(() => null),
    final fn => fn(postId, note),
  };
}
