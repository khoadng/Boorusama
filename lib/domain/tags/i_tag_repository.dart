import 'package:boorusama/domain/tags/tag.dart';

abstract class ITagRepository {
  Future<List<Tag>> getTagsByNamePattern(String stringPattern, int page);
}
