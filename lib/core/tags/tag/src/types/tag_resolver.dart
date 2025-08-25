// Dart imports:
import 'dart:async';

// Project imports:
import '../../../local/cached_tag.dart';
import '../../../local/tag_cache_repository.dart';
import '../../../local/tag_info.dart';
import 'cached_tag_mapper.dart';
import 'tag.dart';
import 'tag_repository.dart';

class TagResolver {
  TagResolver({
    required this.tagCacheBuilder,
    required this.siteHost,
    required this.cachedTagMapper,
    this.tagRepositoryBuilder,
  });

  final Future<TagCacheRepository> Function() tagCacheBuilder;
  final TagRepository Function()? tagRepositoryBuilder;
  final String siteHost;
  final CachedTagMapper cachedTagMapper;

  Future<List<Tag>> resolvePartialTags(List<Tag> tags) async {
    if (tags.isEmpty) return [];

    // Find tags with 0 post count that need resolution
    final tagsNeedingResolution = tags
        .where((tag) => tag.postCount == 0)
        .toList();

    if (tagsNeedingResolution.isEmpty) return tags;

    final tagCache = await tagCacheBuilder();
    final tagNames = tagsNeedingResolution.map((tag) => tag.name).toList();
    final result = await tagCache.resolveTags(siteHost, tagNames);
    final nullCountCachedTags = result.found
        .where((cachedTag) => cachedTag.postCount == null)
        .map((cachedTag) => cachedTag.tagName)
        .toList();

    final allMissingTags = [...result.missing, ...nullCountCachedTags];

    // Try to resolve unknown tags if tag repository is available
    final resolvedTags = await _resolveUnknownTags(allMissingTags);

    // Create a map of tag names to their cached post counts
    final cachedPostCounts = <String, int>{};
    for (final cachedTag in [...result.found, ...resolvedTags]) {
      if (cachedTag.postCount != null) {
        cachedPostCounts[cachedTag.tagName] = cachedTag.postCount!;
      }
    }

    // Update tags with cached post counts
    return tags.map((tag) {
      if (tag.postCount == 0 && cachedPostCounts.containsKey(tag.name)) {
        return tag.copyWith(tag.name, tag.category, cachedPostCounts[tag.name]);
      }
      return tag;
    }).toList();
  }

  Future<List<Tag>> resolveRawTags(Iterable<String> tagNames) async {
    if (tagNames.isEmpty) return [];

    final tagCache = await tagCacheBuilder();
    final result = await tagCache.resolveTags(siteHost, tagNames.toList());
    final unknownCachedTags = result.found
        .where((cachedTag) => cachedTag.category == 'unknown')
        .map((cachedTag) => cachedTag.tagName)
        .toList();

    final allMissingTags = [...result.missing, ...unknownCachedTags];

    // Try to resolve unknown tags if tag repository is available
    final resolvedTags = await _resolveUnknownTags(allMissingTags);

    final resolvedTagNames = resolvedTags.map((tag) => tag.tagName).toSet();

    // Create unknown tags for any remaining missing tags
    final stillMissingTags = result.missing
        .where((missing) => !resolvedTagNames.contains(missing))
        .map(
          (tag) => CachedTag.unknown(
            siteHost: siteHost,
            tagName: tag,
          ),
        )
        .toList();

    final finalTags = [...result.found, ...resolvedTags, ...stillMissingTags];
    final tags = cachedTagMapper.mapCachedTagsToTags(finalTags);

    return tags;
  }

  Future<List<CachedTag>> _resolveUnknownTags(
    List<String> missingTagNames,
  ) async {
    if (tagRepositoryBuilder == null || missingTagNames.isEmpty) {
      return [];
    }

    try {
      final tagRepository = tagRepositoryBuilder!();
      final unknownTags = await tagRepository.getTagsByName(
        missingTagNames.toSet(),
        1,
      );

      // Convert resolved tags to CachedTag and save to cache
      final resolvedTags = <CachedTag>[];
      for (final tag in unknownTags) {
        final cachedTag = CachedTag(
          siteHost: siteHost,
          tagName: tag.name,
          category: tag.category.name,
          postCount: tag.postCount,
        );
        resolvedTags.add(cachedTag);
      }

      // Save to cache for future use
      if (resolvedTags.isNotEmpty) {
        final tagCache = await tagCacheBuilder();
        await tagCache.saveTagsBatch(
          resolvedTags
              .map(
                (tag) => TagInfo(
                  siteHost: siteHost,
                  tagName: tag.tagName,
                  category: tag.category,
                  postCount: tag.postCount,
                  metadata: tag.metadata,
                ),
              )
              .toList(),
        );
      }

      return resolvedTags;
    } catch (e) {
      // If resolution fails, return empty list
      return [];
    }
  }
}
