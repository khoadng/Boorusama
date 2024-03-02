// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';

mixin SearchMixin {
  void submit(String value) {
    selectedTagController.addTag(value);
  }

  void skipToResultWithTag(String tag) {
    selectedTagController.clear();
    selectedTagController.addTag(tag);
    searchHistory.addHistory(selectedTagController.rawTags.join(' '));
  }

  void search() {
    searchHistory.addHistory(selectedTagController.rawTags.join(' '));
  }

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );
    textEditingController.clear();
  }

  void tapHistoryTag(String tag) {
    selectedTagController.addTags(tag.split(' '));
  }

  void tapRawMetaTag(String tag) => textEditingController.text = '$tag:';

  SearchHistoryNotifier get searchHistory;
  TextEditingController get textEditingController;
  SelectedTagController get selectedTagController;
  FilterOperator get filterOperator =>
      getFilterOperator(textEditingController.text);
}
