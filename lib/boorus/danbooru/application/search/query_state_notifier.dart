import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'suggestions_state_notifier.dart';

part 'query_state.dart';
part 'query_state_notifier.freezed.dart';

final queryStateNotifierProvider =
    StateNotifierProvider<QueryStateNotifier>((ref) {
  return QueryStateNotifier(ref);
});

class QueryStateNotifier extends StateNotifier<QueryState> {
  final ProviderReference _ref;
  QueryStateNotifier(ProviderReference ref)
      : _ref = ref,
        super(QueryState.empty());

  void update(String query) {
    String currentInputQuery;

    if (!query.endsWith(' ')) {
      final queries = query.split(' ');
      currentInputQuery = queries.last;
    } else {
      currentInputQuery = '';
    }

    state = state.copyWith(
      query: query,
      partialQuery: currentInputQuery,
    );

    _ref.watch(suggestionsStateNotifier).getSuggestions(currentInputQuery);
  }

  void add(String query) {
    final spaceCharIndex = state.query.lastIndexOf(' ');

    // Space character not found
    if (spaceCharIndex == -1) {
      // First item, replace current query with it
      state = state.copyWith(
        query: query + " ",
        partialQuery: "",
      );
    } else {
      final completedQuery = state.query.substring(0, spaceCharIndex);
      state = state.copyWith(
          query: completedQuery + " " + query + " ", partialQuery: "");
    }

    _ref.watch(suggestionsStateNotifier).getSuggestions(state.partialQuery);
  }

  void clear() {
    state = QueryState.empty();
  }
}
