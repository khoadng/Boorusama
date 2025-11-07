// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../tags/favorites/types.dart';
import '../../../../tags/metatag/types.dart';
import '../../../histories/types.dart';
import '../../../queries/types.dart';
import '../../../selected_tags/providers.dart';
import '../../../selected_tags/types.dart';

class SearchPageController extends ChangeNotifier {
  SearchPageController({
    required this.tagsController,
    required this.textMatchers,
    required this.metatagExtractor,
    this.onSearch,
  });

  final state = ValueNotifier(SearchState.initial);
  final allowSearch = ValueNotifier(false);
  final tagString = ValueNotifier('');
  final focus = FocusNode();
  late final textController = RichTextController(
    matchers: textMatchers,
  );

  final SelectedTagController tagsController;
  final List<TextMatcher>? textMatchers;
  final MetatagExtractor? metatagExtractor;

  final void Function()? onSearch;

  final didSearchOnce = ValueNotifier(false);

  SearchState? _previousState;

  void tapTag(String tag) {
    final operatorPrefix = filterOperator.toString();
    tagsController.addTag(
      TagSearchItem.fromString(
        '$operatorPrefix$tag',
        extractor: metatagExtractor,
      ),
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

    final isRaw = _isRaw(queryType);

    tagsController
      ..clear()
      ..addTag(
        isRaw
            ? TagSearchItem.raw(tag: tag)
            : TagSearchItem.fromString(
                tag,
                extractor: metatagExtractor,
              ),
      );
  }

  void skipToResultWithTags(
    SearchTagSet tags, {
    QueryType? queryType,
  }) {
    tagString.value = tags.spaceDelimitedOriginalTags;
    didSearchOnce.value = true;

    final isRaw = _isRaw(queryType);

    tagsController
      ..clear()
      ..merge(tags, isRaw: isRaw);
  }

  bool _isRaw(QueryType? queryType) {
    return switch (queryType) {
      QueryType.simple => true,
      QueryType.list => false,
      null => false,
    };
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
    tagsController.addTag(
      TagSearchItem.fromString(
        value,
        extractor: metatagExtractor,
      ),
    );
    textController.clear();
    changeState(SearchState.initial);
  }

  void tapHistoryTag(SearchHistory history) {
    tagsController.addTagFromSearchHistory(history);
  }

  void tapRawMetaTag(String tag) => textController.text = '$tag:';

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
