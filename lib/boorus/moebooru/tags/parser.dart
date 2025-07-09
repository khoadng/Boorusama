// Project imports:
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';
import '../tag_summary/types.dart';

Tag tagSummaryToTag(TagSummary tagSummary) => Tag.noCount(
  name: tagSummary.name,
  category: TagCategory.fromLegacyId(tagSummary.category),
);
