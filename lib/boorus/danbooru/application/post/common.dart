// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

List<Post> filter(List<Post> posts, List<String> blacklistedTags) {
  final groups = _parse(blacklistedTags);

  return posts.whereNot((post) => _hasBlacklistedTag(post, groups)).toList();
}

List<Post> filterBlacklisted(List<Post> posts, List<String> blacklistedTags) {
  final groups = _parse(blacklistedTags);

  return posts.where((post) => _hasBlacklistedTag(post, groups)).toList();
}

List<FilterGroup> _parse(List<String> tags) =>
    tags.map(stringToFilterGroup).whereNotNull().toList();

bool _hasBlacklistedTag(Post post, List<FilterGroup> fgs) {
  final tagMap = Map<String, String>.fromIterable(post.tags);
  for (final fg in fgs) {
    if (fg.groupType == FilterGroupType.single) {
      final hasTag = fg.filterItems.map((it) => it.tag).any(tagMap.containsKey);
      if (hasTag) return true;
    } else {
      if (__hasBlacklistedTags(tagMap, fg.filterItems)) return true;
    }
  }

  return false;
}

bool __hasBlacklistedTags(
  Map<String, String> tagMap,
  List<FilterItem> filterItems,
) {
  final operatorGroups =
      filterItems.groupListsBy((element) => element.operator);

  var isBlacklisted = false;

  if (operatorGroups[FilterOperator.none] != null) {
    if (_hasAll(tagMap, operatorGroups[FilterOperator.none]!)) {
      isBlacklisted = true;
    }
  }

  if (operatorGroups[FilterOperator.or] != null) {
    for (final orTag in operatorGroups[FilterOperator.or]!) {
      if (tagMap.containsKey(orTag.tag)) {
        isBlacklisted = true;
        break;
      }
    }
  }

  if (operatorGroups[FilterOperator.not] != null) {
    for (final notTag in operatorGroups[FilterOperator.not]!) {
      if (tagMap.containsKey(notTag.tag)) {
        isBlacklisted = false;
        break;
      }
    }
  }

  return isBlacklisted;
}

bool _hasAll(Map<String, String> tagMap, List<FilterItem> fg) {
  var hasAll = true;
  for (final fi in fg) {
    if (!tagMap.containsKey(fi.tag)) {
      hasAll = false;
      break;
    }
  }

  return hasAll;
}
