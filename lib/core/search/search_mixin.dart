// Project imports:
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'filter_operator.dart';
import 'search_utils.dart';
import 'selected_tag_controller.dart';

typedef HistoryAdder = void Function(SelectedTagController controller);

typedef QueryClearer = void Function();
typedef QueryUpdater = void Function(String query);
typedef QueryGetter = String Function();

typedef SearchStateGetter = SearchState Function();
typedef SearchStateSetter = void Function(SearchState state);

typedef SuggestionFetcher = void Function(String query);

typedef SetAllowSearch = void Function(bool value);
typedef GetAllowedSearch = bool Function();

enum SearchState {
  initial,
  suggestions,
}

mixin SearchMixin {
  void submit(String value) {
    selectedTagController.addTag(value);
    clearQuery();
  }

  void skipToResultWithTag(String tag) {
    selectedTagController.clear();
    selectedTagController.addTag(tag);
    addHistory(selectedTagController);
  }

  void search() {
    addHistory(selectedTagController);
  }

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );

    clearQuery();
  }

  void tapHistoryTag(SearchHistory history) {
    selectedTagController.addTagFromSearchHistory(history);
  }

  void tapRawMetaTag(String tag) => updateQuery('$tag:');

  void onQueryChanged(String previous, String current) {
    if (previous == current) {
      return;
    }

    final currentState = getSearchState();
    final nextState =
        current.isEmpty ? SearchState.initial : SearchState.suggestions;

    if (currentState != nextState) {
      setSearchState(nextState);
    }

    fetchSuggestions(current);
  }

  SearchStateGetter get getSearchState;
  SearchStateSetter get setSearchState;

  SuggestionFetcher get fetchSuggestions;

  HistoryAdder get addHistory;
  QueryClearer get clearQuery;
  QueryUpdater get updateQuery;
  QueryGetter get getQuery;
  SelectedTagController get selectedTagController;
  FilterOperator get filterOperator => getFilterOperator(getQuery());

  SetAllowSearch get setAllowSearch;
  GetAllowedSearch get getAllowedSearch;
}
