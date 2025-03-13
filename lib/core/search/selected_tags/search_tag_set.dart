// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../tags/metatag/metatag.dart';
import '../histories/history.dart';
import '../queries/filter_operator.dart';
import 'query.dart';
import 'tag_search_item.dart';

class SearchTagSet extends Equatable {
  SearchTagSet({
    this.metatagExtractor,
  });

  factory SearchTagSet.empty() => SearchTagSet();

  factory SearchTagSet.fromString(
    String? tags, {
    MetatagExtractor? metatagExtractor,
  }) {
    final tagSet = SearchTagSet(
      metatagExtractor: metatagExtractor,
    )..addTags(queryAsList(tags));

    return tagSet;
  }

  factory SearchTagSet.fromList(
    List<String>? tags, {
    MetatagExtractor? metatagExtractor,
  }) {
    final tagSet = SearchTagSet(
      metatagExtractor: metatagExtractor,
    )..addTags(tags ?? []);

    return tagSet;
  }

  final MetatagExtractor? metatagExtractor;
  final Set<TagSearchItem> _tags = {};

  List<TagSearchItem> get tags => _tags.toList();
  List<String> get rawTags => _tags.toRawStringList();
  String get rawTagsString => _tags.toRawString();

  List<String> get list => _tags.map((e) => e.originalTag).toList();
  String get spaceDelimitedOriginalTags => list.join(' ');

  TagSearchItem _toItem(String tag) =>
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

  TagSearchItem? addTag(
    String tag, {
    bool isRaw = false,
    FilterOperator operator = FilterOperator.none,
  }) {
    if (tag.trim().isEmpty) return null;

    final cleanedTag = tag.trim();
    final tg = isRaw
        ? TagSearchItem.raw(tag: cleanedTag)
        : _toItem(_applyOperator(cleanedTag, operator));

    _tags.add(tg);

    return tg;
  }

  void negateTag(String tag) => addTag(tag, operator: FilterOperator.not);

  void addTags(
    List<String> tags, {
    FilterOperator operator = FilterOperator.none,
  }) {
    if (tags.isEmpty) return;

    _tags.addAll(tags.map((e) => _toItem(_applyOperator(e, operator))));
  }

  void removeTag(TagSearchItem tag) {
    _tags.remove(tag);
  }

  void removeTagString(
    String tag, {
    bool isRaw = false,
  }) {
    final tg = isRaw ? TagSearchItem.raw(tag: tag) : _toItem(tag);
    removeTag(tg);
  }

  void updateTag(TagSearchItem oldTag, String newTag) {
    final tags = _tags.toList();
    final index = tags.indexOf(oldTag);
    if (index != -1) {
      tags[index] = TagSearchItem.raw(tag: newTag);
    }
    _tags
      ..clear()
      ..addAll(tags);
  }

  void clear() {
    _tags.clear();
  }

  SearchTagSet clone() {
    final tagSet = SearchTagSet(metatagExtractor: metatagExtractor);
    tagSet._tags.addAll(_tags);
    return tagSet;
  }

  bool get isEmpty => toString().isEmpty;

  @override
  String toString() {
    final value = jsonEncode(list);

    return switch (value) {
      '' => '',
      '[]' => '',
      '[""]' => '',
      _ => value,
    };
  }

  @override
  List<Object?> get props => [toString()];
}

List<String> queryAsList(String? query) {
  if (query == null) return [];

  final json = tryDecodeJson<List?>(query).getOrElse((_) => null);

  if (json != null) {
    try {
      return [
        for (final tag in json)
          if (tag is String) tag.trim(),
      ].where((tag) => tag.isNotEmpty).toList();
    } catch (e) {
      return query
          .trim()
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList();
    }
  } else {
    return query
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

extension TagSearchItemX on Iterable<TagSearchItem> {
  String toRawString() => map((e) => e.toString()).join(' ');
  List<String> toRawStringList() => map((e) => e.toString()).toList();
}
