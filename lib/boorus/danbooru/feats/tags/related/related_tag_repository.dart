// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'related_tag.dart';

abstract class RelatedTagRepository {
  Future<RelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
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
  }) fetch;

  @override
  Future<RelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
  }) =>
      tryGet(
        query,
        orElse: () => fetch(
          query,
          category: category,
          order: order,
        ),
      );

  @override
  late Cache<RelatedTag> cache;
}
