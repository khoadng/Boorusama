part of 'post_note_bloc.dart';

@freezed
abstract class PostNoteState with _$PostNoteState {
  const factory PostNoteState.empty() = _Empty;
  const factory PostNoteState.loading() = _Loading;
  const factory PostNoteState.fetched({@required List<Note> notes}) = _Fetched;
}
