// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'related_tag.dart';

abstract class RelatedTagRepository {
  Future<RelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
    int? limit,
  });
}

class RelatedTagRepositoryBuilder
    with SimpleCacheMixin<RelatedTag>
    implements RelatedTagRepository {
  RelatedTagRepositoryBuilder({
    required this.fetch,
  }) {
    cache = Cache(
      maxCapacity: 100,
      staleDuration: const Duration(minutes: 30),
    );
  }

  final Future<RelatedTag> Function(
    String query, {
    TagCategory? category,
    RelatedType? order,
    int? limit,
  }) fetch;

  @override
  Future<RelatedTag> getRelatedTag(
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
  late Cache<RelatedTag> cache;
}
