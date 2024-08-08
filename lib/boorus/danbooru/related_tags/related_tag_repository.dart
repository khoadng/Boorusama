// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'danbooru_related_tag.dart';

abstract class RelatedTagRepository {
  Future<DanbooruRelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
    int? limit,
  });
}

class RelatedTagRepositoryBuilder
    with SimpleCacheMixin<DanbooruRelatedTag>
    implements RelatedTagRepository {
  RelatedTagRepositoryBuilder({
    required this.fetch,
  }) {
    cache = Cache(
      maxCapacity: 100,
      staleDuration: const Duration(minutes: 30),
    );
  }

  final Future<DanbooruRelatedTag> Function(
    String query, {
    TagCategory? category,
    RelatedType? order,
    int? limit,
  }) fetch;

  @override
  Future<DanbooruRelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
    int? limit,
  }) =>
      tryGet(
        query,
        orElse: () => fetch(
          query,
          category: category,
          order: order,
          limit: limit,
        ),
      );

  @override
  late Cache<DanbooruRelatedTag> cache;
}
