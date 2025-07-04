// Dart imports:
import 'dart:async';

// Project imports:
import '../../../posts/post/post.dart';
import '../../categories/tag_category.dart';
import '../../local/cached_tag.dart';
import '../../local/tag_cache_repository.dart';
import '../../local/tag_info.dart';
import 'tag.dart';
import 'tag_repository.dart';

class DefaultTagExtractor<T extends Post> implements TagExtractor<T> {
  DefaultTagExtractor({
    required this.tagCacheBuilder,
    required this.siteHost,
    this.tagRepository,
  });

  final Future<TagCacheRepository> Function() tagCacheBuilder;
  final TagRepository? tagRepository;
  final String siteHost;

  @override
  FutureOr<List<Tag>> extractTags(T post) async {
    final tagStrings = post.tags;

    if (tagStrings.isEmpty) return [];

    final tags = await _getFromCache(
      tagStrings.toList(),
      siteHost,
    );

    if (tags.isEmpty) {
      return tagStrings
          .map(
            (tag) => Tag.noCount(
              name: tag,
              category: TagCategory.unknown(),
            ),
          )
          .toList();
    }

    return tags;
  }

  Future<List<Tag>> _getFromCache(
    List<String> tagNames,
    String siteHost,
  ) async {
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

    return _sortTagsByCategory(tags);
  }

  List<Tag> _sortTagsByCategory(List<Tag> tags) {
    final groupedTags = <TagCategory, List<Tag>>{};
    for (final tag in tags) {
      groupedTags.putIfAbsent(tag.category, () => []).add(tag);
    }

    groupedTags.forEach((category, tagList) {
      tagList.sort((a, b) => a.name.compareTo(b.name));
    });

    final categoryOrder = {
      TagCategory.artist().name: 0,
      TagCategory.copyright().name: 1,
      TagCategory.character().name: 2,
      TagCategory.general().name: 3,
      TagCategory.meta().name: 4,
    };

    final sortedCategories = groupedTags.keys.toList()
      ..sort((a, b) {
        final aOrder = categoryOrder[a.name];
        final bOrder = categoryOrder[b.name];

        if (aOrder != null && bOrder != null) {
          return aOrder.compareTo(bOrder);
        }
        if (aOrder != null) return -1;
        if (bOrder != null) return 1;

        // Fall back to category order or name
        final aOrderValue = a.order;
        final bOrderValue = b.order;
        if (aOrderValue != bOrderValue) {
          return (aOrderValue ?? 999).compareTo(bOrderValue ?? 999);
        }
        return a.name.compareTo(b.name);
      });

    return sortedCategories
        .expand((category) => groupedTags[category]!)
        .toList();
  }
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
