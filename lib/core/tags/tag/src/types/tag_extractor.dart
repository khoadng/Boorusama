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
  });

  final String siteHost;
  final TagFetcher fetcher;
  final TagSorter? sorter;
  final Future<TagCacheRepository>? tagCache;

  @override
  FutureOr<List<Tag>> extractTags(
    Post post, {
    ExtractOptions options = const ExtractOptions(),
  }) async {
    final tags = await fetcher(post, options);

    if (tags.isNotEmpty) {
      if (tagCache != null) {
        final cache = await tagCache;
        await cache?.saveTagsBatch(
          tags
              .map((tag) => TagInfo.fromTag(siteHost: siteHost, tag: tag))
              .toList(),
        );
      }
    }

    return sorter?.sortTagsByCategory(tags) ?? tags;
  }
}
