// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../histories/history.dart';
import '../../../queries/query.dart';
import '../../../queries/query_utils.dart';
import '../../../selected_tags/selected_tag_controller.dart';

class SearchPageController extends ChangeNotifier {
  SearchPageController({
    required this.selectedTagController,
    required this.queryPattern,
    this.onSearch,
  });

  final state = ValueNotifier(SearchState.initial);
  final allowSearch = ValueNotifier(false);
  final selectedTagString = ValueNotifier('');
  final focus = FocusNode();
  late final RichTextController textEditingController = RichTextController(
    patternMatchMap: queryPattern ??
        {
          RegExp(''): const TextStyle(color: Colors.white),
        },
    onMatch: (match) {},
  );

  final SelectedTagController selectedTagController;
  final Map<RegExp, TextStyle>? queryPattern;

  final void Function()? onSearch;

  final didSearchOnce = ValueNotifier(false);

  SearchState? _previousState;

  void tapTag(String tag) {
    selectedTagController.addTag(
      tag,
      operator: filterOperator,
    );

    textEditingController.clear();
  }

  void changeState(SearchState newState) {
    _previousState = state.value;
    state.value = newState;
  }

  void skipToResultWithTag(String tag) {
    selectedTagString.value = tag;
    didSearchOnce.value = true;
    selectedTagController
      ..clear()
      ..addTag(tag);
  }

  void search() {
    didSearchOnce.value = true;
    changeState(SearchState.initial);
    selectedTagString.value = selectedTagController.rawTagsString;
    onSearch?.call();
  }

  void onQueryChanged(String query) {
    final currentState = state.value;
    final nextState = query.isEmpty
        ? _previousState == SearchState.options
            ? SearchState.options
            : SearchState.initial
        : SearchState.suggestions;

    if (currentState != nextState) {
      changeState(nextState);
    }
  }

  void submit(String value) {
    selectedTagController.addTag(value);
    textEditingController.clear();
  }

  void tapHistoryTag(SearchHistory history) {
    selectedTagController.addTagFromSearchHistory(history);
  }

  void tapRawMetaTag(String tag) => textEditingController.text = '$tag:';

  // ignore: use_setters_to_change_properties
  void updateQuery(String query) {
    textEditingController.text = query;
  }

  FilterOperator get filterOperator =>
      getFilterOperator(textEditingController.text);

  @override
  void dispose() {
    textEditingController.dispose();
    focus.dispose();

    selectedTagString.dispose();

    super.dispose();
  }
}

enum SearchState {
  initial,
  suggestions,
  options,
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
