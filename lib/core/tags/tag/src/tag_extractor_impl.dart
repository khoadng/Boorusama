// Dart imports:
import 'dart:async';

// Project imports:
import '../../../posts/post/post.dart';
import '../../categories/tag_category.dart';
import 'types/tag.dart';
import 'types/tag_repository.dart';
import 'types/tag_resolver.dart';
import 'types/tag_sorter.dart';

class DefaultTagExtractor<T extends Post> implements TagExtractor<T> {
  DefaultTagExtractor({
    required this.resolver,
    this.sorter,
  });

  final TagResolver resolver;
  final TagSorter? sorter;

  @override
  FutureOr<List<Tag>> extractTags(T post) async {
    final tagStrings = post.tags;

    if (tagStrings.isEmpty) return [];

    final tags = await resolver.resolveTags(tagStrings.toList());

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

    return sorter?.sortTagsByCategory(tags) ?? tags;
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
  FutureOr<List<Tag>> extractTags(T post) async {
    final tags = await fetcher(post.id);

    return sorter?.sortTagsByCategory(tags) ?? tags;
  }
}
