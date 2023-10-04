// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';

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

class SearchHistoryNotifier extends StateNotifier<SearchHistoryState> {
  SearchHistoryNotifier({
    required SearchHistoryRepository searchHistoryRepository,
  })  : _searchHistoryRepository = searchHistoryRepository,
        super(SearchHistoryState.initial());

  final SearchHistoryRepository _searchHistoryRepository;

  Future<void> fetchHistories() async {
    final histories = await _searchHistoryRepository.getHistories();
    state = state.copyWith(
      histories: _sortByDateDesc(histories),
      filteredHistories: _sortByDateDesc(histories),
    );
  }

  Future<void> clearHistories() async {
    final success = await _searchHistoryRepository.clearAll();

    if (success) {
      state = state.copyWith(
        histories: [],
        filteredHistories: [],
      );
    }
  }

  Future<void> addHistory(String history) async {
    // If history length is larger than 255 characters, we will not add it.
    // This is a limitation of Hive.
    if (history.length > 255) return;

    final histories = await _searchHistoryRepository.addHistory(history);
    state = state.copyWith(
      histories: _sortByDateDesc(histories),
    );
    filterHistories(state.currentQuery);
  }

  Future<void> removeHistory(String history) async {
    final histories = await _searchHistoryRepository.removeHistory(history);
    state = state.copyWith(
      histories: _sortByDateDesc(histories),
    );
    filterHistories(state.currentQuery);
  }

  void filterHistories(String pattern) {
    final filteredHistories =
        state.histories.where((e) => e.query.contains(pattern)).toList();
    state = state.copyWith(
      currentQuery: pattern,
      filteredHistories: _sortByDateDesc(filteredHistories),
    );
  }
}

List<SearchHistory> _sortByDateDesc(List<SearchHistory> hist) {
  hist.sort((a, b) {
    return b.createdAt.compareTo(a.createdAt);
  });

  return hist;
}
