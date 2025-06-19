// Project imports:
import 'cached_tag.dart';
import 'tag_alias.dart';
import 'tag_info.dart';

abstract class TagCacheRepository {
  Future<void> saveTag({
    required String siteHost,
    required String tagName,
    required String category,
    int? postCount,
    Map<String, dynamic>? metadata,
  });

  Future<void> saveTagsBatch(List<TagInfo> tagInfos);

  Future<String?> getTagCategory(String siteHost, String tagName);

  Future<TagResolutionResult> resolveTags(
    String siteHost,
    List<String> tagNames,
  );

  Future<void> saveTagAlias({
    required String sourceSite,
    required String sourceTag,
    required String targetSite,
    required String targetTag,
  });

  Future<TagAlias?> getTagAlias(
    String sourceSite,
    String sourceTag,
    String targetSite,
  );

  Future<void> clearTags();
  Future<void> clearAliases();
}
