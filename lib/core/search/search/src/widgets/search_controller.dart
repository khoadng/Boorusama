// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../tags/favorites/src/types/favorite_tag.dart';
import '../../../histories/history.dart';
import '../../../queries/query.dart';
import '../../../queries/query_utils.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../selected_tags/tag.dart';

class SearchPageController extends ChangeNotifier {
  SearchPageController({
    required this.tagsController,
    required this.queryPattern,
    this.onSearch,
  });

  final state = ValueNotifier(SearchState.initial);
  final allowSearch = ValueNotifier(false);
  final tagString = ValueNotifier('');
  final focus = FocusNode();
  late final RichTextController textController = RichTextController(
    patternMatchMap: queryPattern ??
        {
          RegExp(''): const TextStyle(color: Colors.white),
        },
    onMatch: (match) {},
  );

  final SelectedTagController tagsController;
  final Map<RegExp, TextStyle>? queryPattern;

  final void Function()? onSearch;

  final didSearchOnce = ValueNotifier(false);

  SearchState? _previousState;

  void tapTag(String tag) {
    tagsController.addTag(
      tag,
      operator: filterOperator,
    );

    textController.clear();
  }

  void tapFavTag(FavoriteTag tag) {
    tagsController.addTagFromFavTag(tag);

    textController.clear();
  }

  void changeState(SearchState newState) {
    _previousState = state.value;
    state.value = newState;
  }

  void skipToResultWithTag(
    String tag, {
    QueryType? queryType,
  }) {
    tagString.value = tag;
    didSearchOnce.value = true;

    final isRaw = switch (queryType) {
      QueryType.simple => true,
      QueryType.list => false,
      null => false,
    };

    tagsController
      ..clear()
      ..addTag(tag, isRaw: isRaw);
  }

  void search() {
    didSearchOnce.value = true;
    changeState(SearchState.initial);
    tagString.value = tagsController.rawTagsString;
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
    tagsController.addTag(value);
    textController.clear();
    changeState(SearchState.initial);
  }

  void tapHistoryTag(SearchHistory history) {
    tagsController.addTagFromSearchHistory(history);
  }

  void tapRawMetaTag(String tag) => textController.text = '$tag:';

  // ignore: use_setters_to_change_properties
  void updateQuery(String query) {
    textController.text = query;
  }

  FilterOperator get filterOperator => getFilterOperator(textController.text);

  @override
  void dispose() {
    textController.dispose();
    focus.dispose();

    tagString.dispose();

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
