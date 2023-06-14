// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';

enum DisplayState {
  options,
  suggestion,
  result,
}

final searchProvider =
    NotifierProvider.autoDispose<SearchNotifier, DisplayState>(
  SearchNotifier.new,
  dependencies: [
    selectedTagsProvider,
    searchQueryProvider,
    searchHistoryProvider,
    suggestionsProvider,
  ],
);

class SearchNotifier extends AutoDisposeNotifier<DisplayState>
    with SearchHistoryNotifierMixin {
  SearchNotifier() : super();

  @override
  DisplayState build() {
    ref.listen(
      sanitizedQueryProvider,
      (previous, next) {
        if (previous != next) {
          ref.read(suggestionsProvider.notifier).getSuggestions(next);
        }
      },
    );

    ref.listen(
      sanitizedQueryProvider,
      (prev, curr) {
        if (prev != curr) {
          if (curr.isEmpty) {
            if (state != DisplayState.result) {
              resetToOptions();
            }
          } else {
            goToSuggestions();
          }
        }
      },
    );

    _sh.fetchHistories();

    return DisplayState.options;
  }

  void submit(String value) {
    _selectedTags.addTag(value);
    resetToOptions();
  }

  void skipToResultWithTag(String tag) {
    _selectedTags.clear();
    _selectedTags.addTag(tag);
    _sh.addHistory(_rawSelectedTagString);
    goToResult();
  }

  void search() {
    _sh.addHistory(_rawSelectedTagString);
    goToResult();
  }

  void tapTag(String tag) {
    _selectedTags.addTag(tag);
    if (state == DisplayState.suggestion) {
      resetToOptions();
    }
  }

  void tapHistoryTag(String tag) {
    _selectedTags.addTags(tag.split(' '));
  }

  void removeSelectedTag(TagSearchItem tag) {
    _selectedTags.removeTag(tag);
    resetToOptions();
  }

  void tapRawMetaTag(String tag) => _query.state = '$tag:';

  void goToSuggestions() => state = DisplayState.suggestion;

  void resetToOptions() {
    _query.state = '';
    state = DisplayState.options;
  }

  void goToResult() {
    state = DisplayState.result;
  }

  SearchHistoryNotifier get _sh => ref.read(searchHistoryProvider.notifier);
  StateController<String> get _query => ref.read(searchQueryProvider.notifier);
  SelectedTagsNotifier get _selectedTags =>
      ref.read(selectedTagsProvider.notifier);
  String get _rawSelectedTagString =>
      ref.read(selectedTagsProvider).map((e) => e.toString()).join(' ');
}

mixin SearchHistoryNotifierMixin<T> on AutoDisposeNotifier<T> {
  void clearHistories() =>
      ref.read(searchHistoryProvider.notifier).clearHistories();
  void removeHistory(SearchHistory history) =>
      ref.read(searchHistoryProvider.notifier).removeHistory(history.query);
}
