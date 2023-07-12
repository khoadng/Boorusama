// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/search/search_mixin.dart';

enum DisplayState {
  options,
  suggestion,
  result,
}

final searchProvider = NotifierProvider.autoDispose<SearchNotifier, void>(
  SearchNotifier.new,
  dependencies: [
    selectedTagsProvider,
    searchQueryProvider,
    searchHistoryProvider,
    suggestionsProvider,
  ],
);

final displayStateProvider = StateProvider<DisplayState>((ref) {
  return DisplayState.options;
});

class SearchNotifier extends AutoDisposeNotifier<void> with SearchMixin {
  SearchNotifier() : super();

  @override
  void build() {}

  @override
  FilterOperator get filterOperator => ref.read(filterOperatorProvider);

  @override
  StateController<String> get queryController =>
      ref.read(searchQueryProvider.notifier);

  @override
  SearchHistoryNotifier get searchHistory =>
      ref.read(searchHistoryProvider.notifier);

  @override
  List<TagSearchItem> get selectedTagItems => ref.read(selectedTagsProvider);

  @override
  SelectedTagsNotifier get selectedTags =>
      ref.read(selectedTagsProvider.notifier);

  @override
  StateController<DisplayState> get stateController =>
      ref.read(displayStateProvider.notifier);
}
