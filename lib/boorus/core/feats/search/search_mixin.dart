// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';

mixin SearchMixin {
  void submit(String value) {
    selectedTagController.addTag(value);
    resetToOptions();
  }

  void skipToResultWithTag(String tag) {
    selectedTagController.clear();
    selectedTagController.addTag(tag);
    searchHistory
        .addHistory(selectedTagItems.map((e) => e.toString()).join(' '));
    goToResult();
  }

  void search() {
    searchHistory
        .addHistory(selectedTagItems.map((e) => e.toString()).join(' '));
    goToResult();
  }

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );
    queryController.clear();

    if (stateController.value == DisplayState.suggestion) {
      resetToOptions();
    }
  }

  void tapHistoryTag(String tag) {
    selectedTagController.addTags(tag.split(' '));
  }

  void tapRawMetaTag(String tag) => queryController.text = '$tag:';

  void goToSuggestions() => stateController.value = DisplayState.suggestion;

  void resetToOptions() {
    queryController.clear();
    stateController.value = DisplayState.options;
  }

  void goToResult() {
    stateController.value = DisplayState.result;
  }

  SearchHistoryNotifier get searchHistory;
  TextEditingController get queryController;
  ValueNotifier<DisplayState> get stateController;
  SelectedTagController get selectedTagController;

  FilterOperator get filterOperator;
  List<TagSearchItem> get selectedTagItems;
}
