// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/search_histories/search_histories.dart';

class SearchHistoryState {
  SearchHistoryState({
    required this.histories,
    required this.filteredHistories,
    required this.currentQuery,
  });

  final List<SearchHistory> histories;
  final List<SearchHistory> filteredHistories;
  final String currentQuery;

  SearchHistoryState.initial()
      : histories = [],
        filteredHistories = [],
        currentQuery = '';

  SearchHistoryState copyWith({
    List<SearchHistory>? histories,
    List<SearchHistory>? filteredHistories,
    String? currentQuery,
  }) {
    return SearchHistoryState(
      histories: histories ?? this.histories,
      filteredHistories: filteredHistories ?? this.filteredHistories,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

class SearchHistoryNotifier extends AsyncNotifier<SearchHistoryState> {
  @override
  Future<SearchHistoryState> build() async {
    final histories = await ref.watch(searchHistoryRepoProvider).getHistories();

    return SearchHistoryState.initial().copyWith(
      histories: _sortByDateDesc(histories),
      filteredHistories: _sortByDateDesc(histories),
    );
  }

  Future<void> clearHistories() async {
    final success = await ref.read(searchHistoryRepoProvider).clearAll();

    if (success) {
      state = AsyncData(SearchHistoryState.initial());
    }
  }

  Future<void> addHistory(String history) async {
    // If history length is larger than 255 characters, we will not add it.
    // This is a limitation of Hive.
    if (history.length > 255) return;

    final currentState = state.value;

    if (currentState == null) return;

    final histories =
        await ref.read(searchHistoryRepoProvider).addHistory(history);
    state = AsyncData(currentState.copyWith(
      histories: _sortByDateDesc(histories),
    ));

    filterHistories(currentState.currentQuery);
  }

  Future<void> removeHistory(String history) async {
    final currentState = state.value;

    if (currentState == null) return;

    final histories =
        await ref.read(searchHistoryRepoProvider).removeHistory(history);

    state = AsyncData(currentState.copyWith(
      histories: _sortByDateDesc(histories),
    ));

    filterHistories(currentState.currentQuery);
  }

  void filterHistories(String pattern) {
    final currentState = state.value;

    if (currentState == null) return;

    final filteredHistories =
        currentState.histories.where((e) => e.query.contains(pattern)).toList();
    state = AsyncData(currentState.copyWith(
      currentQuery: pattern,
      filteredHistories: _sortByDateDesc(filteredHistories),
    ));
  }

  void resetFilter() {
    final query = state.value?.currentQuery ?? '';

    if (query.isEmpty) return;

    state = const AsyncLoading();

    filterHistories('');
  }
}

List<SearchHistory> _sortByDateDesc(List<SearchHistory> hist) {
  hist.sort((a, b) {
    return b.createdAt.compareTo(a.createdAt);
  });

  return hist;
}
