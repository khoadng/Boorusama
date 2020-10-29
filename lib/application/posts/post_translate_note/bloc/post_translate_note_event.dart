part of 'post_translate_note_bloc.dart';

abstract class PostTranslateNoteEvent extends Equatable {
  const PostTranslateNoteEvent();

  @override
  List<Object> get props => [];
}

class GetTranslatedNotes extends PostTranslateNoteEvent {
  final int postId;

  GetTranslatedNotes({this.postId});
}
