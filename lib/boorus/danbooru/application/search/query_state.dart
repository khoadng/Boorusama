part of 'query_state_notifier.dart';

@freezed
abstract class QueryState with _$QueryState {
  const factory QueryState({
    @required String query,
    @required String partialQuery,
    @required List<String> completedQueryItems,
  }) = _QueryState;

  factory QueryState.empty() => QueryState(
        query: "",
        partialQuery: "",
        completedQueryItems: [],
      );
}
