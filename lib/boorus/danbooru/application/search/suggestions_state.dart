part of 'suggestions_state_notifier.dart';

@freezed
abstract class SuggestionsState with _$SuggestionsState {
  const factory SuggestionsState({
    @required List<Tag> tags,
    @required SuggestionsMonitoringState suggestionsMonitoringState,
  }) = _SuggestionsState;

  factory SuggestionsState.initial() => SuggestionsState(
        tags: <Tag>[],
        suggestionsMonitoringState: SuggestionsMonitoringState.none(),
      );
}

@freezed
abstract class SuggestionsMonitoringState with _$SuggestionsMonitoringState {
  const factory SuggestionsMonitoringState.none() = _None;
  const factory SuggestionsMonitoringState.inProgress() = _InProgress;
  const factory SuggestionsMonitoringState.completed() = _Completed;
  const factory SuggestionsMonitoringState.error() = _Error;
}
