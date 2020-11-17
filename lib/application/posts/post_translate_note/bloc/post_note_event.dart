part of 'post_note_bloc.dart';

@freezed
abstract class PostNoteEvent with _$PostNoteEvent {
  const factory PostNoteEvent.requested({@required int postId}) = _Requested;
}
