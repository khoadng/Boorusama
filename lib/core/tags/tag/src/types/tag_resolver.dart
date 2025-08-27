// Dart imports:
import 'dart:async';

// Project imports:
import '../../../local/cached_tag.dart';
import '../../../local/tag_cache_repository.dart';
import '../../../local/tag_info.dart';
import 'cached_tag_mapper.dart';
import 'tag.dart';
import 'tag_repository.dart';

enum TagCacheLifetime {
  short(Duration(hours: 6)),
  medium(Duration(days: 2)),
  long(Duration(days: 7)),
  extended(Duration(days: 30));

  const TagCacheLifetime(this.duration);
  final Duration duration;
}

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

    final refreshedResult = await _refreshStaleTagsInResult(result);

    final nullCountCachedTags = refreshedResult.found
        .where((cachedTag) => cachedTag.postCount == null)
        .map((cachedTag) => cachedTag.tagName)
        .toList();

    final allMissingTags = [...refreshedResult.missing, ...nullCountCachedTags];

    // Try to resolve unknown tags if tag repository is available
    final resolvedTags = await _resolveUnknownTags(allMissingTags);

    // Create a map of tag names to their cached post counts
    final cachedPostCounts = <String, int>{};
    for (final cachedTag in [...refreshedResult.found, ...resolvedTags]) {
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

    // Check for stale tags and refresh them
    final refreshedResult = await _refreshStaleTagsInResult(result);

    final unknownCachedTags = refreshedResult.found
        .where((cachedTag) => cachedTag.category == 'unknown')
        .map((cachedTag) => cachedTag.tagName)
        .toList();

    final allMissingTags = [...refreshedResult.missing, ...unknownCachedTags];

    // Try to resolve unknown tags if tag repository is available
    final resolvedTags = await _resolveUnknownTags(allMissingTags);

    final resolvedTagNames = resolvedTags.map((tag) => tag.tagName).toSet();

    // Create unknown tags for any remaining missing tags
    final stillMissingTags = refreshedResult.missing
        .where((missing) => !resolvedTagNames.contains(missing))
        .map(
          (tag) => CachedTag.unknown(
            siteHost: siteHost,
            tagName: tag,
          ),
        )
        .toList();

    final finalTags = {
      ...refreshedResult.found.where(
        (tag) => !resolvedTagNames.contains(tag.tagName),
      ), // remove resolved tags from found
      ...resolvedTags,
      ...stillMissingTags,
    };
    final tags = cachedTagMapper.mapCachedTagsToTags(finalTags.toList());

    return tags;
  }

  Future<TagResolutionResult> _refreshStaleTagsInResult(
    TagResolutionResult result,
  ) async {
    final staleTags = <CachedTag>[];
    final freshTags = <CachedTag>[];

    for (final tag in result.found) {
      if (_isStale(tag)) {
        staleTags.add(tag);
      } else {
        freshTags.add(tag);
      }
    }

    final refreshedTags = await _refreshStaleTags(staleTags);

    return TagResolutionResult(
      found: [...freshTags, ...refreshedTags],
      missing: result.missing,
    );
  }

  bool _isStale(CachedTag tag) {
    final updatedAt = tag.updatedAt;

    if (updatedAt == null) return true;

    final now = DateTime.now().toUtc();
    final interval = _getRefreshInterval(tag.postCount ?? 0);

    return now.difference(updatedAt) > interval;
  }

  Duration _getRefreshInterval(int postCount) {
    final lifetime = switch (postCount) {
      0 || < 100 => TagCacheLifetime.short,
      < 1000 => TagCacheLifetime.medium,
      < 10000 => TagCacheLifetime.long,
      _ => TagCacheLifetime.extended,
    };
    return lifetime.duration;
  }

  Future<List<CachedTag>> _refreshStaleTags(List<CachedTag> staleTags) async {
    if (tagRepositoryBuilder == null || staleTags.isEmpty) return staleTags;

    try {
      final tagRepository = tagRepositoryBuilder!();
      final staleTagNames = staleTags.map((t) => t.tagName).toSet();

      final freshTags = await tagRepository.getTagsByName(staleTagNames, 1);

      final refreshedCachedTags = <CachedTag>[];
      final refreshedNames = <String>{};

      for (final tag in freshTags) {
        final refreshed = CachedTag(
          siteHost: siteHost,
          tagName: tag.name,
          category: tag.category.name,
          postCount: tag.postCount,
          updatedAt: DateTime.now().toUtc(),
        );
        refreshedCachedTags.add(refreshed);
        refreshedNames.add(tag.name);
      }

      final tagCache = await tagCacheBuilder();
      await tagCache.saveTagsBatch(
        refreshedCachedTags.map((t) => TagInfo.fromCachedTag(t)).toList(),
      );

      final unchangedStale = staleTags
          .where((tag) => !refreshedNames.contains(tag.tagName))
          .toList();

      return [...refreshedCachedTags, ...unchangedStale];
    } catch (e) {
      return staleTags;
    }
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

      final resolvedTags = <CachedTag>[];
      for (final tag in unknownTags) {
        final cachedTag = CachedTag(
          siteHost: siteHost,
          tagName: tag.name,
          category: tag.category.name,
          postCount: tag.postCount,
          updatedAt: DateTime.now().toUtc(),
        );
        resolvedTags.add(cachedTag);
      }

      return resolvedTags;
    } catch (e) {
      return [];
    }
  }
}
