// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';

enum DisplayState {
  options,
  suggestion,
  result,
}

class SearchPageController extends ChangeNotifier with SearchMixin {
  SearchPageController({
    required this.filterOperatorBuilder,
    required this.queryController,
    required this.searchHistory,
    required this.selectedTagController,
    required this.stateController,
  }) : super();

  final FilterOperator Function() filterOperatorBuilder;

  @override
  FilterOperator get filterOperator => filterOperatorBuilder();

  @override
  final TextEditingController queryController;

  @override
  final SearchHistoryNotifier searchHistory;

  @override
  List<TagSearchItem> get selectedTagItems => selectedTagController.tags;

  @override
  final SelectedTagController selectedTagController;

  @override
  final ValueNotifier<DisplayState> stateController;
}
