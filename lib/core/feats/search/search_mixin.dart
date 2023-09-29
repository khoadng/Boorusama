// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';

mixin SearchMixin {
  void submit(String value) {
    selectedTagController.addTag(value);
    resetToOptions();
  }

  void skipToResultWithTag(String tag) {
    selectedTagController.clear();
    selectedTagController.addTag(tag);
    searchHistory.addHistory(selectedTagController.rawTags.join(' '));
    goToResult();
  }

  void search() {
    searchHistory.addHistory(selectedTagController.rawTags.join(' '));
    goToResult();
  }

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );
    textEditingController.clear();

    if (searchStateController.value == DisplayState.suggestion) {
      resetToOptions();
    }
  }

  void tapHistoryTag(String tag) {
    selectedTagController.addTags(tag.split(' '));
  }

  void tapRawMetaTag(String tag) => textEditingController.text = '$tag:';

  void goToSuggestions() =>
      searchStateController.value = DisplayState.suggestion;

  void resetToOptions() {
    textEditingController.clear();
    searchStateController.value = DisplayState.options;
  }

  void goToResult() {
    searchStateController.value = DisplayState.result;
  }

  SearchHistoryNotifier get searchHistory;
  TextEditingController get textEditingController;
  ValueNotifier<DisplayState> get searchStateController;
  SelectedTagController get selectedTagController;
  FilterOperator get filterOperator =>
      getFilterOperator(textEditingController.text);
}
