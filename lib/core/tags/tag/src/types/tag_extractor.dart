// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../../../../../foundation/utils/collection_utils.dart';
import '../../../../posts/post/types.dart';
import '../../../categories/types.dart';
import '../../../local/types.dart';
import 'cached_tag_mapper.dart';
import 'tag.dart';
import 'tag_display.dart';
import 'tag_sorter.dart';

abstract class TagExtractor {
  FutureOr<List<Tag>> extractTags(
    Post post, {
    ExtractOptions options = const ExtractOptions(),
  });

  FutureOr<List<Tag>>? extractTagsBatch(
    List<Post> posts, {
    ExtractOptions options = const ExtractOptions(),
  });

  FutureOr<({Set<String> characterTags, Set<String> artistTags})>
  extractArtistCharacterTags(
    Post post, {
    ExtractOptions options = const ExtractOptions(),
  });

  static List<Tag> extractTagsFromGenericPost(Post post) {
    return post.tags
        .map(
          (e) => Tag.noCount(
            name: e,
            category: TagCategory.unknown,
          ),
        )
        .toList();
  }
}

typedef CachePolicyResolver = Duration Function(CachedTag tag);

class CachePolicy {
  static CachePolicyResolver byPostCount() =>
      (tag) => switch (tag.postCount) {
        null || <= 0 => const Duration(days: 1),
        < 100 => const Duration(days: 3),
        < 1000 => const Duration(days: 7),
        < 10000 => const Duration(days: 14),
        _ => const Duration(days: 30),
      };

  static CachePolicyResolver fixedDuration(Duration duration) =>
      (tag) => duration;

  static CachePolicyResolver aMonth() =>
      fixedDuration(const Duration(days: 30));
}

sealed class _CacheResult {
  const _CacheResult();

  factory _CacheResult.from({
    required TagResolutionResult? result,
    required Set<String> requestedTags,
    required CachedTagMapper cachedTagMapper,
    CachePolicyResolver? expire,
  }) => switch (result) {
    TagResolutionResult(:final found, :final missing) =>
      _isCompleteHit(found, missing, requestedTags)
          ? _isStale(found, expire)
                ? _Miss(found.map((e) => e.tagName).toList())
                : _Hit(
                    cachedTagMapper.mapCachedTagsToTags(found),
                  )
          : _Miss(missing),
    _ => const _Miss([]),
  };

  static bool _isCompleteHit(
    List<CachedTag> found,
    List<String> missing,
    Set<String> requestedTags,
  ) =>
      missing.isEmpty &&
      found.isNotEmpty &&
      found.length == requestedTags.length &&
      _hasCompleteData(found, requestedTags);

  static bool _hasCompleteData(
    List<CachedTag> found,
    Set<String> requestedTags,
  ) {
    final resolvedTagNames = found.map((tag) => tag.tagName).toSet();
    return requestedTags.every(resolvedTagNames.contains);
  }

  static bool _isStale(List<CachedTag> found, CachePolicyResolver? expire) {
    final now = DateTime.now();
    final resolver = expire ?? CachePolicy.byPostCount();

    bool stale(CachedTag tag) {
      final cacheDuration = resolver(tag);
      final staleCutoff = now.subtract(cacheDuration);
      return tag.updatedAt?.isBefore(staleCutoff) ?? true;
    }

    return found.any(stale);
  }
}

class _Hit extends _CacheResult {
  const _Hit(this.tags);
  final List<Tag> tags;
}

class _Miss extends _CacheResult {
  const _Miss(this.missing);
  final List<String> missing;
}

typedef TagFetcherExtended =
    Future<List<Tag>> Function(
      Post post,
      ExtractOptions options,
      List<String> missingTags,
    );

typedef TagNormalizer = Set<String> Function(Set<String> tags);

TagFetcher createCachedTagFetcher({
  required String siteHost,
  required Future<TagCacheRepository>? tagCache,
  required CachedTagMapper cachedTagMapper,
  required TagFetcherExtended fetcher,
  CachePolicyResolver? cachePolicy,
  TagNormalizer? normalizer,
}) => (post, options) async {
  final tags = normalizer != null
      ? normalizer(post.tags).toList()
      : post.tags.toList();

  Future<TagResolutionResult?> safeResolve() async {
    try {
      return (await tagCache)?.resolveTags(
        siteHost,
        tags,
      );
    } catch (_) {
      return null;
    }
  }

  return switch (_CacheResult.from(
    result: await safeResolve(),
    requestedTags: tags.toSet(),
    cachedTagMapper: cachedTagMapper,
    expire: cachePolicy,
  )) {
    _Hit(:final tags) => tags,
    _Miss(:final missing) => fetcher(post, options, missing).then(
      (tags) => tags,
    ),
  };
};

typedef CacheWhenResolver = bool Function(Tag tag);

class CacheWhen {
  static CachedTag? _get(Tag tag, List<CachedTag> found) =>
      found.firstWhereOrNull((e) => e.tagName == tag.name);

  // For case when tags have meaningful data to prevent cache degradation
  static CacheWhenResolver withCache(
    TagResolutionResult? result,
  ) => switch (result) {
    TagResolutionResult(:final found, :final missing) =>
      (tag) =>
          // Cache missing tags - new data is better than no data
          missing.contains(tag.name) ||
          // Upgrade existing cached tags when we have better data
          (found.isNotEmpty &&
              switch (_get(tag, found)) {
                CachedTag(category: 'unknown') => true,
                CachedTag(postCount: null || 0) when tag.postCount > 0 => true,
                CachedTag(postCount: final count?) => tag.postCount != count,
                _ => false,
              }),
    // No cache data available - don't cache
    _ => (tag) => false,
  };
}

class TagExtractorBuilder implements TagExtractor {
  TagExtractorBuilder({
    required this.siteHost,
    required this.fetcher,
    required this.tagCache,
    this.sorter,
    this.fetcherBatch,
    this.artistCategory,
    this.characterCategory,
  });

  final String siteHost;
  final TagFetcher fetcher;
  final TagFetcherBatch? fetcherBatch;
  final TagSorter? sorter;
  final Future<TagCacheRepository>? tagCache;
  final TagCategory? artistCategory;
  final TagCategory? characterCategory;

  @override
  FutureOr<List<Tag>> extractTags(
    Post post, {
    ExtractOptions options = const ExtractOptions(),
  }) async {
    final tags = await fetcher(post, options);

    await _cacheIfNeeded(tags);

    return sorter?.sortTagsByCategory(tags) ?? tags;
  }

  @override
  FutureOr<List<Tag>> extractTagsBatch(
    List<Post> posts, {
    ExtractOptions options = const ExtractOptions(),
  }) async {
    if (fetcherBatch != null) {
      final tags = await fetcherBatch!(posts, options);

      await _cacheIfNeeded(tags);

      return sorter?.sortTagsByCategory(tags) ?? tags;
    } else {
      final allTags = <Tag>[];
      final cancelToken = options.cancelToken;

      for (final post in posts) {
        if (cancelToken?.isCancelled ?? false) {
          break;
        }
        final tags = await extractTags(post, options: options);
        allTags.addAll(tags);
      }

      return sorter?.sortTagsByCategory(allTags) ?? allTags;
    }
  }

  @override
  FutureOr<({Set<String> characterTags, Set<String> artistTags})>
  extractArtistCharacterTags(
    Post post, {
    ExtractOptions options = const ExtractOptions(),
  }) async {
    final tags = await extractTags(post, options: options);

    final characterTags = <String>{};
    final artistTags = <String>{};

    final effectiveCharacterCategory =
        characterCategory ?? TagCategory.character();
    final effectiveArtistCategory = artistCategory ?? TagCategory.artist();

    for (final tag in tags) {
      if (tag.category == effectiveCharacterCategory) {
        characterTags.add(tag.rawName);
      } else if (tag.category == effectiveArtistCategory) {
        artistTags.add(tag.rawName);
      }
    }

    return (characterTags: characterTags, artistTags: artistTags);
  }

  Future<void> _cacheIfNeeded(List<Tag> tags) async {
    if (tagCache == null) return;

    final cache = await tagCache;
    if (cache == null) return;

    await cache.saveTagsBatchIfNeeded(
      tags: tags,
      siteHost: siteHost,
    );
  }
}

extension ConditionalSaveX on TagCacheRepository {
  Future<void> saveTagsBatchIfNeeded({
    required List<Tag> tags,
    required String siteHost,
  }) async {
    if (tags.isEmpty) return;

    final currentCacheTags = await resolveTags(
      siteHost,
      tags.map((e) => e.name).toList(),
    );
    final shouldCache = CacheWhen.withCache(currentCacheTags);

    final validTags = tags.where(shouldCache).toList();
    if (validTags.isNotEmpty) {
      await saveTagsBatch(
        validTags
            .map((tag) => TagInfo.fromTag(siteHost: siteHost, tag: tag))
            .toList(),
      );
    }
  }
}

/// Process tags in chunks with timeout
Future<void> processTagsInChunks({
  required List<String> missing,
  required Future<void> Function(String tagName) fetcher,
  String Function(String)? normalizer,
  Duration timeout = const Duration(seconds: 15),
  int chunkSize = 5,
}) async {
  if (missing.isEmpty) return;

  final chunks = missing.chunk(chunkSize);
  final startTime = DateTime.now();

  for (final chunk in chunks) {
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed >= timeout) break;

    final remainingTime = timeout - elapsed;

    try {
      await Future.wait(
        chunk.map(
          (tagName) => fetcher(
            normalizer?.call(tagName) ?? tagName,
          ).timeout(remainingTime),
        ),
      ).timeout(remainingTime);
    } catch (e) {
      break;
    }

    if (chunk != chunks.last) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}
