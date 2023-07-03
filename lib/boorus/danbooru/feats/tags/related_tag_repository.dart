// Project imports:
import 'related_tag.dart';

abstract class RelatedTagRepository {
  Future<RelatedTag> getRelatedTag(String query);
}
