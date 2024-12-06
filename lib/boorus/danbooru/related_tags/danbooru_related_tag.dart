// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/caching.dart';

class DanbooruRelatedTag extends Equatable {
  const DanbooruRelatedTag({
    required this.query,
    required this.tags,
    required this.wikiPageTags,
  });

  const DanbooruRelatedTag.empty()
      : query = '',
        wikiPageTags = const [],
        tags = const [];

  final String query;
  final List<DanbooruRelatedTagItem> tags;
  final List<Tag> wikiPageTags;

  DanbooruRelatedTag copyWith({
    List<DanbooruRelatedTagItem>? tags,
    List<Tag>? wikiPageTags,
    String? query,
  }) =>
      DanbooruRelatedTag(
        query: query ?? this.query,
        wikiPageTags: wikiPageTags ?? this.wikiPageTags,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [query, tags, wikiPageTags];
}

class DanbooruRelatedTagItem extends Equatable {
  const DanbooruRelatedTagItem({
    required this.tag,
    required this.category,
    required this.jaccardSimilarity,
    required this.cosineSimilarity,
    required this.overlapCoefficient,
    required this.frequency,
    required this.postCount,
  });

  final TagCategory category;
  final String tag;
  final double jaccardSimilarity;
  final double cosineSimilarity;
  final double overlapCoefficient;
  final double frequency;
  final int postCount;

  @override
  List<Object?> get props => [
        tag,
        category,
        jaccardSimilarity,
        cosineSimilarity,
        overlapCoefficient,
        frequency,
      ];
}

List<DanbooruRelatedTagItem> generateDummyTags(int count) => [
      for (var i = 0; i < count; i++)
        DanbooruRelatedTagItem(
          tag: generateRandomWord(3, 12),
          cosineSimilarity: 1,
          jaccardSimilarity: 1,
          overlapCoefficient: 1,
          frequency: 1,
          postCount: 1,
          category: switch (i % 10) {
            0 => TagCategory.artist(),
            1 => TagCategory.character(),
            2 => TagCategory.copyright(),
            3 => TagCategory.meta(),
            _ => TagCategory.general(),
          },
        ),
    ];

enum RelatedType {
  jaccard,
  cosine,
  overlap,
  frequency,
}

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
