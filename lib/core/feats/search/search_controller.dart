// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';

class SearchPageController extends ChangeNotifier with SearchMixin {
  SearchPageController({
    required this.textEditingController,
    required this.searchHistory,
    required this.selectedTagController,
    required this.suggestions,
    required this.focus,
  }) : super() {
    textEditingController.addListener(_onTextChanged);
  }

  final FocusNode focus;

  final SuggestionsNotifier suggestions;

  final TextEditingController textEditingController;

  final SearchHistoryNotifier searchHistory;

  @override
  final SelectedTagController selectedTagController;

  void _onTextChanged() {
    final query = textEditingController.text;

    suggestions.getSuggestions(query);
  }

  @override
  void dispose() {
    textEditingController.removeListener(_onTextChanged);
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
}
