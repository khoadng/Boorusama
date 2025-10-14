// Project imports:
import '../types/cached_tag.dart';
import '../types/tag_alias.dart';
import '../types/tag_cache_repository.dart';
import '../types/tag_info.dart';

class EmptyTagCacheRepository implements TagCacheRepository {
  @override
  Future<void> saveTag({
    required String siteHost,
    required String tagName,
    required String category,
    int? postCount,
    Map<String, dynamic>? metadata,
  }) async {
    // No-op
  }

  @override
  Future<String?> getTagCategory(String siteHost, String tagName) async {
    return null;
  }

  @override
  Future<void> saveTagAlias({
    required String sourceSite,
    required String sourceTag,
    required String targetSite,
    required String targetTag,
  }) async {
    // No-op
  }

  @override
  Future<TagAlias?> getTagAlias(
    String sourceSite,
    String sourceTag,
    String targetSite,
  ) async {
    return null;
  }

  @override
  Future<void> clearTags() async {
    // No-op
  }

  @override
  Future<void> clearAliases() async {
    // No-op
  }

  @override
  Future<void> saveTagsBatch(List<TagInfo> tagInfos) async {
    // No-op
  }

  @override
  Future<TagResolutionResult> resolveTags(
    String siteHost,
    List<String> tagNames,
  ) async {
    // Empty repository returns all tags as missing
    return TagResolutionResult(
      found: const [],
      missing: tagNames,
    );
  }

  @override
  Future<void> dispose() async {
    // No-op
  }
}
