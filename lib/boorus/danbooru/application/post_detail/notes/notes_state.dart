part of 'notes_state_notifier.dart';

@freezed
abstract class NotesState with _$NotesState {
  const factory NotesState.initial() = _Initial;
  const factory NotesState.loading() = _Loading;
  const factory NotesState.fetched({@required List<Note> notes}) = _Fetched;
  const factory NotesState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
