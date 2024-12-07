// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/core/tags/configs/tag_info.dart';
import 'package:boorusama/core/tags/metatag/extractor.dart';
import 'filter_operator.dart';
import 'tag_search_item.dart';

class SelectedTagController extends ValueNotifier<List<TagSearchItem>> {
  SelectedTagController({
    required this.metatagExtractor,
  }) : super([]);

  SelectedTagController.fromBooruBuilder({
    required BooruBuilder? builder,
    required TagInfo tagInfo,
  }) : this(
          metatagExtractor: builder?.metatagExtractorBuilder?.call(tagInfo),
        );

  final MetatagExtractor? metatagExtractor;
  final Set<TagSearchItem> _tags = {};

  List<TagSearchItem> get tags => _tags.toList();
  List<String> get rawTags => _tags.toRawStringList();
  String get rawTagsString => _tags.toRawString();

  TagSearchItem _toItem(
    String tag,
  ) =>
      TagSearchItem.fromString(tag, metatagExtractor);

  String _applyOperator(String tag, FilterOperator operator) =>
      '${filterOperatorToString(operator)}$tag';

  void addTagFromSearchHistory(SearchHistory history) {
    if (history.queryType == QueryType.list) {
      final tags = history.queryAsList();
      addTags(tags);
    } else {
      addTag(
        history.query,
        isRaw: true,
      );
    }
  }

  void addTag(
    String tag, {
    bool isRaw = false,
    FilterOperator operator = FilterOperator.none,
  }) {
    if (tag.isEmpty) return;

    if (isRaw) {
      _tags.add(TagSearchItem.raw(tag: tag));
    } else {
      _tags.add(_toItem(_applyOperator(tag, operator)));
    }

    value = _tags.toList();
  }

  void negateTag(String tag) => addTag(tag, operator: FilterOperator.not);

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

  void updateTag(TagSearchItem oldTag, String newTag) {
    final tags = _tags.toList();
    final index = tags.indexOf(oldTag);
    tags[index] = TagSearchItem.raw(tag: newTag);
    _tags.clear();
    _tags.addAll(tags);
    value = _tags.toList();
  }

  void clear() {
    _tags.clear();
    value = _tags.toList();
  }
}

extension TagSearchItemX on Iterable<TagSearchItem> {
  String toRawString() => map((e) => e.toString()).join(' ');
  List<String> toRawStringList() => map((e) => e.toString()).toList();
}
