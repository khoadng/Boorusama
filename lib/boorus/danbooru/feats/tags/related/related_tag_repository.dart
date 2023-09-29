// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'related_tag.dart';

abstract class RelatedTagRepository {
  Future<RelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
  });
}
