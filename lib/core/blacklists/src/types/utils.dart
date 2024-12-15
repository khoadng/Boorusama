// Package imports:
import 'package:collection/collection.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'blacklisted_tag.dart';
import 'blacklisted_tags_sort_type.dart';

String joinBlackTagItems(List<String> tagItems, String currentQuery) {
  final tagString = [
    ...tagItems,
    if (currentQuery.isNotEmpty) currentQuery,
  ].join(' ');

  return tagString;
}

List<BlacklistedTag> sortBlacklistedTags(
  IList<BlacklistedTag> tags,
  BlacklistedTagsSortType sortType,
) =>
    switch (sortType) {
      BlacklistedTagsSortType.recentlyAdded =>
        tags.sortedByCompare((e) => e.createdDate, (a, b) => b.compareTo(a)),
      // BlacklistedTagsSortType.recentlyUpdated =>
      //   tags.sortedByCompare((e) => e.updatedDate, (a, b) => b.compareTo(a)),
      BlacklistedTagsSortType.nameAZ =>
        tags.sortedByCompare((e) => e.name, (a, b) => a.compareTo(b)),
      BlacklistedTagsSortType.nameZA =>
        tags.sortedByCompare((e) => e.name, (a, b) => b.compareTo(a))
    };
