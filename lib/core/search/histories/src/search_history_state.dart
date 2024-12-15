// Project imports:
import 'search_history.dart';

class SearchHistoryState {
  SearchHistoryState({
    required this.histories,
    required this.filteredHistories,
    required this.currentQuery,
  });

  SearchHistoryState.initial()
      : histories = [],
        filteredHistories = [],
        currentQuery = '';

  final List<SearchHistory> histories;
  final List<SearchHistory> filteredHistories;
  final String currentQuery;

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
