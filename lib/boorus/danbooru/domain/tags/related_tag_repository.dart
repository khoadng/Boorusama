// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/related_tag.dart';

abstract class RelatedTagRepository {
  Future<RelatedTag> getRelatedTag(String query);
}
