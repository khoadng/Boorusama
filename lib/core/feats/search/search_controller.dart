// Flutter imports:
import 'package:boorusama/utils/stream/text_editing_controller_utils.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';
import 'package:rxdart/rxdart.dart';

class SearchPageController extends ChangeNotifier with SearchMixin {
  SearchPageController({
    required this.textEditingController,
    required this.searchHistory,
    required this.selectedTagController,
    required this.suggestions,
    required this.focus,
    required this.searchState,
  }) : super() {
    textEditingController.textAsStream().pairwise().listen((pair) {
      onQueryChanged(pair.first, pair.last);
    }).addTo(_subscriptions);
  }

  final ValueNotifier<SearchState> searchState;

  final FocusNode focus;

  final SuggestionsNotifier suggestions;

  final TextEditingController textEditingController;

  final SearchHistoryNotifier searchHistory;

  @override
  final SelectedTagController selectedTagController;

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
  QueryUpdater get updateQuery => (query) => textEditingController.text = query;

  @override
  SearchStateGetter get getSearchState => () => searchState.value;

  @override
  SearchStateSetter get setSearchState => (state) => searchState.value = state;

  @override
  SuggestionFetcher get fetchSuggestions => suggestions.getSuggestions;
}
