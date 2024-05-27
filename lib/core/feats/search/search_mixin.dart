// Project imports:
import 'filter_operator.dart';
import 'search_utils.dart';

typedef HistoryAdder = void Function(String tag);

typedef QueryClearer = void Function();
typedef QueryUpdater = void Function(String query);
typedef QueryGetter = String Function();

typedef SearchStateGetter = SearchState Function();
typedef SearchStateSetter = void Function(SearchState state);

typedef SuggestionFetcher = void Function(String query);

typedef SetAllowSearch = void Function(bool value);
typedef GetAllowedSearch = bool Function();
typedef FocusRequester = void Function();
typedef FocusUnfocuser = void Function();

enum SearchState {
  initial,
  suggestions,
}

mixin SearchMixin {
  void submit(String value) {
    // if not end with space, add space
    var query = value;
    if (!query.endsWith(' ')) {
      query += ' ';
    }

    updateQuery(query);
  }

  void backToInitial() {
    setSearchState(SearchState.initial);
  }

  void skipToResultWithTag(String tag) {
    addHistory(tag);
    updateQuery('$tag ');
  }

  void search() {
    final query = getQuery();
    addHistory(query);
  }

  void tapTag(String tag) {
    // example: "tag1 ta" then user tap "tag2", it should be "tag1 tag2 "
    final query = getQuery();
    final lastSpaceIndex = query.lastIndexOf(' ');
    final newQuery = '${query.substring(0, lastSpaceIndex + 1)}$tag ';
    updateQuery(newQuery);
    requestFocus();
  }

  void tapHistoryTag(String tag) {
    // append to the end
    final query = getQuery();
    final newQuery = '$query $tag ';

    updateQuery(newQuery);
  }

  void tapRawMetaTag(String tag) {
    final query = getQuery();

    final newQuery = '$query $tag:';

    updateQuery(newQuery);
  }

  void onQueryChanged(String previous, String current) {
    if (current == previous) return;

    setAllowSearch(current.isNotEmpty);

    if (current.isEmpty) {
      if (!previous.endsWith('(') || !previous.endsWith('{')) {
        setSearchState(SearchState.initial);
        unfocus();

        return;
      }
    }

    if (current.endsWith(' ')) {
      if (!previous.endsWith('(') || !previous.endsWith('{')) {
        setSearchState(SearchState.initial);
        requestFocus();
        return;
      }
    }

    if (previous.isEmpty && current.isNotEmpty ||
        previous.endsWith(' ') && !current.endsWith(' ')) {
      setSearchState(SearchState.suggestions);
    }

    // only search the last word
    final query = current.split(' ').lastOrNull;

    if (query != null && query.isNotEmpty) {
      fetchSuggestions(query);
    }
  }

  List<String> getCurrentRawTags() {
    return getQuery().trim().split(' ');
  }

  SearchStateGetter get getSearchState;
  SearchStateSetter get setSearchState;

  SuggestionFetcher get fetchSuggestions;

  FocusRequester get requestFocus;
  FocusUnfocuser get unfocus;

  HistoryAdder get addHistory;
  QueryClearer get clearQuery;
  QueryUpdater get updateQuery;
  QueryGetter get getQuery;
  FilterOperator get filterOperator => getFilterOperator(getQuery());

  SetAllowSearch get setAllowSearch;
  GetAllowedSearch get getAllowedSearch;
}
