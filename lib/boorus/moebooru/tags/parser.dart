// Project imports:
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/tag/types.dart';
import '../tag_summary/types.dart';

Tag tagSummaryToTag(TagSummary tagSummary) => Tag.noCount(
  name: tagSummary.name,
  category: TagCategory.fromLegacyId(tagSummary.category),
);
