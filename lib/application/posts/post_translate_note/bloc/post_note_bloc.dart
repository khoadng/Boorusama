import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_note_repository.dart';
import 'package:boorusama/domain/posts/note.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_note_event.dart';
part 'post_note_state.dart';

part 'post_note_bloc.freezed.dart';

class PostNoteBloc extends Bloc<PostNoteEvent, PostNoteState> {
  final INoteRepository _noteRepository;

  PostNoteBloc({
    @required INoteRepository noteRepository,
  })  : _noteRepository = noteRepository,
        super(PostNoteState.empty());

  @override
  Stream<PostNoteState> mapEventToState(
    PostNoteEvent event,
  ) async* {
    yield* event.map(
      requested: (e) => _mapRequestedToState(e),
    );
  }

  Stream<PostNoteState> _mapRequestedToState(_Requested event) async* {
    yield const PostNoteState.loading();
    final notes = await _noteRepository.getNotesFrom(event.postId);
    yield PostNoteState.fetched(notes: notes);
  }
}
