// Dart imports:
import 'dart:async';

// Project imports:
import '../../../categories/tag_category.dart';
import '../../../local/cached_tag.dart';
import '../../../local/tag_cache_repository.dart';
import '../../../local/tag_info.dart';
import 'tag.dart';
import 'tag_repository.dart';

class TagResolver {
  TagResolver({
    required this.tagCacheBuilder,
    required this.siteHost,
    this.tagRepository,
  });

  final Future<TagCacheRepository> Function() tagCacheBuilder;
  final TagRepository? tagRepository;
  final String siteHost;

  Future<List<Tag>> resolveTags(List<String> tagNames) async {
    if (tagNames.isEmpty) return [];

    final tagCache = await tagCacheBuilder();
    final result = await tagCache.resolveTags(siteHost, tagNames);

    // Try to resolve unknown tags if tag repository is available
    final resolvedTags = <CachedTag>[];
    if (tagRepository != null && result.missing.isNotEmpty) {
      try {
        final unknownTags =
            await tagRepository!.getTagsByName(result.missing.toSet(), 1);

        // Convert resolved tags to CachedTag and save to cache
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
      } catch (e) {
        // If resolution fails, continue with cached results only
      }
    }

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
    final tags = _mapCachedTagsToTags(finalTags);

    return tags;
  }

  List<Tag> _mapCachedTagsToTags(List<CachedTag> cachedTags) => cachedTags
      .map(
        (cachedTag) => Tag(
          name: cachedTag.tagName,
          category: TagCategory.fromLegacyIdString(cachedTag.category),
          postCount: cachedTag.postCount ?? 0,
        ),
      )
      .toList();
}
