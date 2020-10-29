part of 'post_translate_note_bloc.dart';

abstract class PostTranslateNoteState extends Equatable {
  const PostTranslateNoteState();

  @override
  List<Object> get props => [];
}

class PostTranslateNoteInitial extends PostTranslateNoteState {}

class PostTranslateNoteInProgress extends PostTranslateNoteState {}

class PostTranslateNoteFetched extends PostTranslateNoteState {
  final List<Note> notes;

  PostTranslateNoteFetched({this.notes});
}
