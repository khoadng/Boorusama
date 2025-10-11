// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../tags/favorites/favorited.dart';
import '../../tags/metatag/types.dart';
import '../histories/history.dart';
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
    );

    for (final tag in queryAsList(tags)) {
      tagSet.addTag(TagSearchItem.fromString(tag, extractor: metatagExtractor));
    }

    return tagSet;
  }

  factory SearchTagSet.fromList(
    List<String>? tags, {
    MetatagExtractor? metatagExtractor,
  }) {
    final tagItems = (tags ?? [])
        .map(
          (tag) => TagSearchItem.fromString(tag, extractor: metatagExtractor),
        )
        .toList();
    final tagSet = SearchTagSet(
      metatagExtractor: metatagExtractor,
    )..addTags(tagItems);

    return tagSet;
  }

  final MetatagExtractor? metatagExtractor;
  final Set<TagSearchItem> _tags = {};

  List<TagSearchItem> get tags => _tags.toList();
  List<String> get rawTags => _tags.toRawStringList();
  String get rawTagsString => _tags.toRawString();

  List<String> get list => _tags.map((e) => e.originalTag).toList();
  String get spaceDelimitedOriginalTags => list.join(' ');

  void addTagFromSearchHistory(SearchHistory history) {
    if (history.queryType == QueryType.list) {
      final tags = history.queryAsList();
      for (final tag in tags) {
        addTag(TagSearchItem.fromString(tag, extractor: metatagExtractor));
      }
    } else {
      addTag(TagSearchItem.raw(tag: history.query));
    }
  }

  void addTagFromFavTag(FavoriteTag tag) {
    addTag(
      tag.queryType == QueryType.simple
          ? TagSearchItem.raw(tag: tag.name)
          : TagSearchItem.fromString(tag.name, extractor: metatagExtractor),
    );
  }

  void merge(
    SearchTagSet other, {
    bool isRaw = false,
  }) {
    if (other.isEmpty) return;

    for (final tag in other._tags) {
      addTag(
        isRaw || tag.isRaw ? TagSearchItem.raw(tag: tag.originalTag) : tag,
      );
    }
  }

  void addTag(TagSearchItem tag) {
    _tags.add(tag);
  }

  void addTags(List<TagSearchItem> tags) {
    _tags.addAll(tags);
  }

  void removeTag(TagSearchItem tag) {
    _tags.remove(tag);
  }

  void updateTag(TagSearchItem oldTag, TagSearchItem newTag) {
    final tags = _tags.toList();
    final index = tags.indexOf(oldTag);
    if (index != -1) {
      tags[index] = newTag;
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
