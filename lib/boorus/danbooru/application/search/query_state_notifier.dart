import 'dart:collection';

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
    if (query.trim().isEmpty) {
      // Make sure input is not empty
      state = state.copyWith(
        query: query,
        completedQueryItems: [],
        partialQuery: '',
      );
      return;
    }

    final removeMode = query.length < state.query.length;
    String currentInputQuery;
    var completedQueryItems = state.completedQueryItems;
    final queries = query.split(' ');

    if (!query.endsWith(' ')) {
      currentInputQuery = queries.last;
    } else {
      currentInputQuery = '';

      if (removeMode) {
        completedQueryItems.removeLast();
      } else {
        completedQueryItems.add(query.trim().split(' ').last);
      }
    }

    state = state.copyWith(
      query: currentInputQuery,
      partialQuery: currentInputQuery,
      completedQueryItems: completedQueryItems,
    );

    print(state.completedQueryItems);

    _ref.watch(suggestionsStateNotifier).getSuggestions(currentInputQuery);
  }

  void add(String query) {
    final spaceCharIndex = state.query.lastIndexOf(' ');
    final completedQueries =
        LinkedHashSet<String>.from([...state.completedQueryItems, query])
            .toList();

    // Space character not found
    if (spaceCharIndex == -1) {
      // First item, replace current query with it
      state = state.copyWith(
        query: "",
        partialQuery: "",
        completedQueryItems: completedQueries,
      );
    } else {
      // final completedQuery = state.query.substring(0, spaceCharIndex);
      state = state.copyWith(
        query: "",
        partialQuery: "",
        completedQueryItems: completedQueries,
      );
    }
    print(state.completedQueryItems);
    _ref.watch(suggestionsStateNotifier).getSuggestions(state.partialQuery);
  }

  void clear() {
    state = QueryState.empty();
  }

  void remove(String query) {
    state = state.copyWith(
      completedQueryItems: [...state.completedQueryItems..remove(query)],
    );
  }
}
