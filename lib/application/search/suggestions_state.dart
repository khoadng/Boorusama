part of 'suggestions_state_notifier.dart';

@freezed
abstract class SuggestionsState with _$SuggestionsState {
  const factory SuggestionsState.empty() = _Empty;
  const factory SuggestionsState.loading() = _Loading;
  const factory SuggestionsState.fetched({
    @required List<Tag> tags,
  }) = _Fetched;
  const factory SuggestionsState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
