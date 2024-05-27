// Flutter imports:
import 'package:boorusama/flutter.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/utils/stream/text_editing_controller_utils.dart';

class SearchPageController extends ChangeNotifier with SearchMixin {
  SearchPageController({
    required this.textEditingController,
    required this.searchHistory,
    required this.suggestions,
    required this.focus,
    required this.searchState,
    required this.allowSearch,
  }) : super() {
    textEditingController.textAsStream().pairwise().listen((pair) {
      onQueryChanged(pair.first, pair.last);
    }).addTo(_subscriptions);
  }

  final ValueNotifier<bool> allowSearch;

  final ValueNotifier<SearchState> searchState;

  final FocusNode focus;

  final SuggestionsNotifier suggestions;

  final TextEditingController textEditingController;

  final SearchHistoryNotifier searchHistory;

  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }

  @override
  HistoryAdder get addHistory => searchHistory.addHistory;

  @override
  QueryClearer get clearQuery => () => textEditingController.clear();

  @override
  QueryGetter get getQuery => () => textEditingController.text;

  @override
  QueryUpdater get updateQuery =>
      (query) => textEditingController.setTextAndCollapseSelection(query);

  @override
  SearchStateGetter get getSearchState => () => searchState.value;

  @override
  SearchStateSetter get setSearchState => (state) => searchState.value = state;

  @override
  SuggestionFetcher get fetchSuggestions => suggestions.getSuggestions;

  @override
  GetAllowedSearch get getAllowedSearch => () => allowSearch.value;

  @override
  SetAllowSearch get setAllowSearch => (value) => allowSearch.value = value;

  @override
  FocusRequester get requestFocus => () => focus.requestFocus();

  @override
  FocusUnfocuser get unfocus => () => focus.unfocus();
}
