// Project imports:
import '../../../categories/types.dart';
import '../../../local/types.dart';
import 'tag.dart';

typedef TagCategoryMapper = TagCategory Function(CachedTag cachedTag);

class CachedTagMapper {
  const CachedTagMapper({
    this.categoryMapper,
  });

  final TagCategoryMapper? categoryMapper;

  List<Tag> mapCachedTagsToTags(List<CachedTag> cachedTags) => cachedTags
      .map(
        (cachedTag) => Tag(
          name: cachedTag.tagName,
          category:
              categoryMapper?.call(cachedTag) ??
              TagCategory.fromLegacyIdString(cachedTag.category),
          postCount: cachedTag.postCount ?? 0,
        ),
      )
      .toList();
}
