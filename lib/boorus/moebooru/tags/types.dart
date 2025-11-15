// Project imports:
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/tag/types.dart';

Set<String> extractMoebooruTagsByCategory(
  Set<String> postTags,
  Map<String, Tag> allTagsMap,
  TagCategory category,
) {
  return postTags
      .map((name) => allTagsMap[name])
      .nonNulls
      .where((tag) => tag.category == category)
      .map((tag) => tag.rawName)
      .toSet();
}
