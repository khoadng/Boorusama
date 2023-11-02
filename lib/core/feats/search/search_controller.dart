// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';

enum DisplayState {
  options,
  suggestion,
  result,
}

class SearchPageController extends ChangeNotifier with SearchMixin {
  SearchPageController({
    required this.textEditingController,
    required this.searchHistory,
    required this.selectedTagController,
    required this.searchStateController,
    required this.suggestions,
  }) : super() {
    textEditingController.addListener(_onTextChanged);
  }

  final SuggestionsNotifier suggestions;

  @override
  final TextEditingController textEditingController;

  @override
  final SearchHistoryNotifier searchHistory;

  @override
  final SelectedTagController selectedTagController;

  @override
  final ValueNotifier<DisplayState> searchStateController;

  void _onTextChanged() {
    final query = textEditingController.text;

    if (query.isEmpty) {
      if (searchStateController.value != DisplayState.result) {
        resetToOptions();
      }
    } else {
      goToSuggestions();
    }

    suggestions.getSuggestions(query);
  }

  @override
  void dispose() {
    textEditingController.removeListener(_onTextChanged);
    super.dispose();
  }
}
