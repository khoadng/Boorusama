// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'filter_operator.dart';
import 'tag_search_item.dart';

class SelectedTagController extends ValueNotifier<List<TagSearchItem>> {
  SelectedTagController({
    required this.tagInfo,
  }) : super([]);

  final TagInfo tagInfo;
  final Set<TagSearchItem> _tags = {};

  List<TagSearchItem> get tags => _tags.toList();
  List<String> get rawTags => _tags.map((e) => e.toString()).toList();

  TagSearchItem _toItem(String tag) => TagSearchItem.fromString(tag, tagInfo);
  String _applyOperator(String tag, FilterOperator operator) =>
      '${filterOperatorToString(operator)}$tag';

  void addTag(
    String tag, {
    FilterOperator operator = FilterOperator.none,
  }) {
    _tags.add(_toItem(_applyOperator(tag, operator)));
    value = _tags.toList();
  }

  void addTags(
    List<String> tags, {
    FilterOperator operator = FilterOperator.none,
  }) {
    _tags.addAll(tags.map((e) => _toItem(_applyOperator(e, operator))));
    value = _tags.toList();
  }

  void removeTag(TagSearchItem tag) {
    _tags.remove(tag);
    value = _tags.toList();
  }

  void clear() {
    _tags.clear();
    value = _tags.toList();
  }
}
