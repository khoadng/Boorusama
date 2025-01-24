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

  final searchState = ValueNotifier(SearchState.initial);
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
  }

  void search() {
    selectedTagString.value = selectedTagController.rawTagsString;
    onSearch?.call();
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
