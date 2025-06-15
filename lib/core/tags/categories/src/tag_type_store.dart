// Project imports:
import '../../local/tag_info.dart';

abstract class TagTypeStore {
  Future<void> saveTag(TagInfo tagInfo);
  Future<String?> getTagCategory(String siteHost, String tagName);
  Future<void> clear();

  Future<void> saveOrUpdateTagsBatch(List<TagInfo> tagInfos);
}
