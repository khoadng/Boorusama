// Project imports:
import '../../../../foundation/loggers.dart';
import '../../local/tag_cache_repository.dart';
import '../../local/tag_info.dart';
import 'tag_type_store.dart';

class BooruTagTypeStore extends TagTypeStore {
  BooruTagTypeStore({
    required this.cacheRepository,
    required this.logger,
  });

  final TagCacheRepository cacheRepository;
  final Logger logger;

  @override
  Future<void> saveTag(TagInfo tagInfo) async {
    await cacheRepository.saveTag(
      siteHost: tagInfo.siteHost,
      tagName: tagInfo.tagName,
      category: tagInfo.category,
      postCount: tagInfo.postCount,
      metadata: tagInfo.metadata,
    );
  }

  @override
  Future<String?> getTagCategory(String siteHost, String tagName) async {
    return cacheRepository.getTagCategory(siteHost, tagName);
  }

  @override
  Future<void> clear() async {
    await cacheRepository.clearTags();
  }

  @override
  Future<void> saveOrUpdateTagsBatch(List<TagInfo> tagInfos) async {
    if (tagInfos.isEmpty) return;

    try {
      await cacheRepository.saveTagsBatch(tagInfos);
    } catch (e) {
      logger.logE(
        'BooruTagTypeStore',
        'Failed to save tags batch: $e',
      );
    }
  }
}
