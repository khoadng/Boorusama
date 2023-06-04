// Project imports:
import 'package:boorusama/boorus/danbooru/features/tags/models/related_tag.dart';

abstract class RelatedTagRepository {
  Future<RelatedTag> getRelatedTag(String query);
}
