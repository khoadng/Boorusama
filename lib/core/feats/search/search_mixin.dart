// Project imports:
import 'filter_operator.dart';
import 'search_utils.dart';
import 'selected_tag_controller.dart';

typedef HistoryAdder = void Function(String tag);

typedef QueryClearer = void Function();
typedef QueryUpdater = void Function(String query);
typedef QueryGetter = String Function();

typedef SearchStateGetter = SearchState Function();
typedef SearchStateSetter = void Function(SearchState state);

typedef SuggestionFetcher = void Function(String query);

enum SearchState {
  initial,
  suggestions,
}

mixin SearchMixin {
  void submit(String value) {
    selectedTagController.addTag(value);
  }

  void skipToResultWithTag(String tag) {
    selectedTagController.clear();
    selectedTagController.addTag(tag);
    addHistory(selectedTagController.rawTags.join(' '));
  }

  void search() {
    addHistory(selectedTagController.rawTags.join(' '));
  }

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );

    clearQuery();
  }

  void tapHistoryTag(String tag) {
    selectedTagController.addTags(tag.split(' '));
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

  List<String> getCurrentRawTags() {
    return selectedTagController.rawTags;
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
}
