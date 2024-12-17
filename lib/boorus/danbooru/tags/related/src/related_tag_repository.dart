// Dart imports:

// Dart imports:
import 'dart:convert';

// Project imports:
import '../../../../../core/foundation/caching.dart';
import '../../../../../core/tags/categories/tag_category.dart';
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
        jsonEncode({
          'query': query,
          'category': category?.name,
          'order': order?.name,
          'limit': limit,
        }),
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
