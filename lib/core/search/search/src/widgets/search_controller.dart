// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rxdart/rxdart.dart';

// Project imports:
import '../../../../utils/stream/text_editing_controller_utils.dart';
import '../../../histories/history.dart';
import '../../../histories/providers.dart';
import '../../../queries/query.dart';
import '../../../queries/query_utils.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../suggestions/suggestions_notifier.dart';

class SearchPageController extends ChangeNotifier {
  SearchPageController({
    required this.textEditingController,
    required this.searchHistory,
    required this.selectedTagController,
    required this.suggestions,
    required this.focus,
    required this.searchState,
    required this.allowSearch,
  }) : super() {
    textEditingController.textAsStream().pairwise().listen((pair) {
      onQueryChanged(pair.first, pair.last);
    }).addTo(_subscriptions);

    selectedTagController.addListener(_onSelectedTagChanged);
  }

  final ValueNotifier<bool> allowSearch;

  final ValueNotifier<SearchState> searchState;

  final FocusNode focus;

  final SuggestionsNotifier suggestions;

  final TextEditingController textEditingController;

  final SearchHistoryNotifier searchHistory;

  final SelectedTagController selectedTagController;

  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  void dispose() {
    _subscriptions.dispose();
    selectedTagController.removeListener(_onSelectedTagChanged);
    super.dispose();
  }

  void _onSelectedTagChanged() {
    allowSearch.value = selectedTagController.rawTags.isNotEmpty;
  }

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );

    textEditingController.clear();
  }

  void skipToResultWithTag(String tag) {
    selectedTagController
      ..clear()
      ..addTag(tag);
    searchHistory.addHistoryFromController(selectedTagController);
  }

  void search() {
    searchHistory.addHistoryFromController(selectedTagController);
  }

  void submit(String value) {
    selectedTagController.addTag(value);
    textEditingController.clear();
  }

  void tapHistoryTag(SearchHistory history) {
    selectedTagController.addTagFromSearchHistory(history);
  }

  void tapRawMetaTag(String tag) => textEditingController.text = '$tag:';

  void onQueryChanged(String previous, String current) {
    if (previous == current) {
      return;
    }

    final currentState = searchState.value;
    final nextState =
        current.isEmpty ? SearchState.initial : SearchState.suggestions;

    if (currentState != nextState) {
      searchState.value = nextState;
    }

    suggestions.getSuggestions(current);
  }

  // ignore: use_setters_to_change_properties
  void updateQuery(String query) {
    textEditingController.text = query;
  }

  FilterOperator get filterOperator =>
      getFilterOperator(textEditingController.text);
}

enum SearchState {
  initial,
  suggestions,
}

class InheritedSearchPageController extends InheritedWidget {
  const InheritedSearchPageController({
    required this.controller,
    required super.child,
    super.key,
  });

  final SearchPageController controller;

  static SearchPageController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedSearchPageController>();
    if (result == null) {
      throw FlutterError(
        'InheritedSearchPageController.of was called with a context that does not contain a SearchPageController.',
      );
    }
    return result.controller;
  }

  @override
  bool updateShouldNotify(InheritedSearchPageController oldWidget) {
    return oldWidget.controller != controller;
  }
}
