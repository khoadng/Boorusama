import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_note_repository.dart';
import 'package:boorusama/domain/posts/note.dart';
import 'package:equatable/equatable.dart';

part 'post_translate_note_event.dart';
part 'post_translate_note_state.dart';

class PostTranslateNoteBloc
    extends Bloc<PostTranslateNoteEvent, PostTranslateNoteState> {
  final INoteRepository _noteRepository;

  PostTranslateNoteBloc(this._noteRepository)
      : super(PostTranslateNoteInitial());

  @override
  Stream<PostTranslateNoteState> mapEventToState(
    PostTranslateNoteEvent event,
  ) async* {
    if (event is GetTranslatedNotes) {
      yield PostTranslateNoteInProgress();
      final notes = await _noteRepository.getNotesFrom(event.postId);
      yield PostTranslateNoteFetched(notes: notes);
    }
  }
}
