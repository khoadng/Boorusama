// Dart imports:
import 'dart:async';

// Project imports:
import '../../../../posts/post/post.dart';
import '../../../categories/tag_category.dart';
import 'tag.dart';
import 'tag_sorter.dart';

abstract class TagExtractor<T extends Post> {
  FutureOr<List<Tag>> extractTags(
    T post, {
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

class TagExtractorBuilder<T extends Post> implements TagExtractor<T> {
  TagExtractorBuilder({
    required this.fetcher,
    this.sorter,
  });

  final TagFetcher fetcher;
  final TagSorter? sorter;

  @override
  FutureOr<List<Tag>> extractTags(
    T post, {
    ExtractOptions options = const ExtractOptions(),
  }) async {
    final tags = await fetcher(post, options);

    return sorter?.sortTagsByCategory(tags) ?? tags;
  }
}
