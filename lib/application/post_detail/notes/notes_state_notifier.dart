import 'package:boorusama/domain/posts/note.dart';
import 'package:boorusama/infrastructure/repositories/posts/note_repository.dart';
import 'package:boorusama/domain/posts/i_note_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notes_state.dart';
part 'notes_state_notifier.freezed.dart';

final notesStateNotifierProvider =
    StateNotifierProvider<NotesStateNotifier>((ref) => NotesStateNotifier(ref));

class NotesStateNotifier extends StateNotifier<NotesState> {
  final INoteRepository _noteRepository;

  NotesStateNotifier(ProviderReference ref)
      : _noteRepository = ref.read(noteProvider),
        super(NotesState.initial());

  void getNotes(int postId) async {
    try {
      state = NotesState.loading();

      final notes = await _noteRepository.getNotesFrom(postId);

      state = NotesState.fetched(notes: notes);
    } on Exception {
      state = NotesState.error(name: "Error", message: "Something went wrong");
    }
  }

  void clearNotes() => state = NotesState.initial();
}
