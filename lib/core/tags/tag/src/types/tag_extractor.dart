// Dart imports:
import 'dart:async';

// Project imports:
import '../../../../posts/post/post.dart';
import '../../../categories/tag_category.dart';
import '../../../local/tag_cache_repository.dart';
import '../../../local/tag_info.dart';
import 'tag.dart';
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

  static List<Tag> extractTagsFromGenericPost(Post post) {
    return post.tags
        .map(
          (e) => Tag.noCount(
            name: e,
            category: TagCategory.unknown(),
          ),
        )
        .toList();
  }
}

class TagExtractorBuilder implements TagExtractor {
  TagExtractorBuilder({
    required this.siteHost,
    required this.fetcher,
    required this.tagCache,
    this.sorter,
    this.fetcherBatch,
  });

  final String siteHost;
  final TagFetcher fetcher;
  final TagFetcherBatch? fetcherBatch;
  final TagSorter? sorter;
  final Future<TagCacheRepository>? tagCache;

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

  Future<void> _cacheIfNeeded(List<Tag> tags) async {
    if (tags.isNotEmpty) {
      if (tagCache != null) {
        // Only save tags with meaningful data to prevent cache degradation
        final qualityTags = tags
            .where(
              (tag) =>
                  tag.category != TagCategory.unknown() && tag.postCount > 0,
            )
            .toList();

        if (qualityTags.isNotEmpty) {
          final cache = await tagCache;
          await cache?.saveTagsBatch(
            qualityTags
                .map((tag) => TagInfo.fromTag(siteHost: siteHost, tag: tag))
                .toList(),
          );
        }
      }
    }
  }
}
