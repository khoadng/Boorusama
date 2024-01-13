// Project imports:
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
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

extension RelatedTagRepositoryX on RelatedTagRepository {
  Future<RelatedTag> getRelatedTagSafe(
    String query, {
    required bool hasStrictSFW,
    required TagInfo tagInfo,
    TagCategory? category,
    RelatedType? order,
    int? limit,
  }) async {
    try {
      final nsfwTags = tagInfo.r18Tags;
      final sfwTags = filterNsfwRawTagString(
        query,
        nsfwTags,
        shouldFilter: hasStrictSFW,
      );

      if (sfwTags.isEmpty) return const RelatedTag.empty();
      if (query.isEmpty) return const RelatedTag.empty();

      final relatedTag = await getRelatedTag(
        query,
        category: category,
        order: order,
        limit: limit,
      );

      final data = hasStrictSFW
          ? relatedTag.copyWith(
              tags: relatedTag.tags
                  .where((e) => isSfwTag(
                        value: e.tag,
                        nsfwTags: nsfwTags,
                      ))
                  .toList())
          : relatedTag;

      return data;
    } catch (e) {
      return const RelatedTag.empty();
    }
  }
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
