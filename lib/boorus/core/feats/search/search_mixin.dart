// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'filter_operator.dart';
import 'search_history_notifier.dart';
import 'search_notifier.dart';
import 'selected_tags_notifier.dart';
import 'tag_search_item.dart';

mixin SearchMixin {
  void submit(String value) {
    selectedTags.addTag(value);
    resetToOptions();
  }

  void skipToResultWithTag(String tag) {
    selectedTags.clear();
    selectedTags.addTag(tag);
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
    selectedTags.addTag(
      tag,
      operator: filterOperator,
    );
    queryController.state = '';

    if (stateController.state == DisplayState.suggestion) {
      resetToOptions();
    }
  }

  void tapHistoryTag(String tag) {
    selectedTags.addTags(tag.split(' '));
  }

  void tapRawMetaTag(String tag) => queryController.state = '$tag:';

  void goToSuggestions() => stateController.state = DisplayState.suggestion;

  void resetToOptions() {
    queryController.state = '';
    stateController.state = DisplayState.options;
  }

  void goToResult() {
    stateController.state = DisplayState.result;
  }

  SearchHistoryNotifier get searchHistory;
  StateController<String> get queryController;
  StateController<DisplayState> get stateController;
  SelectedTagsNotifier get selectedTags;

  FilterOperator get filterOperator;
  List<TagSearchItem> get selectedTagItems;
}
