// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/string.dart';

class RelatedTag extends Equatable {
  const RelatedTag({
    required this.query,
    required this.tags,
    required this.wikiPageTags,
  });

  const RelatedTag.empty()
      : query = '',
        wikiPageTags = const [],
        tags = const [];

  final String query;
  final List<RelatedTagItem> tags;
  final List<Tag> wikiPageTags;

  RelatedTag copyWith({
    List<RelatedTagItem>? tags,
    List<Tag>? wikiPageTags,
    String? query,
  }) =>
      RelatedTag(
        query: query ?? this.query,
        wikiPageTags: wikiPageTags ?? this.wikiPageTags,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [query, tags, wikiPageTags];
}

class RelatedTagItem extends Equatable {
  const RelatedTagItem({
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

List<RelatedTagItem> generateDummyTags(int count) => [
      for (var i = 0; i < count; i++)
        RelatedTagItem(
          tag: generateRandomWord(3, 12),
          cosineSimilarity: 1,
          jaccardSimilarity: 1,
          overlapCoefficient: 1,
          frequency: 1,
          postCount: 1,
          category: switch (i % 10) {
            0 => TagCategory.artist,
            1 => TagCategory.character,
            2 => TagCategory.copyright,
            3 => TagCategory.meta,
            _ => TagCategory.general,
          },
        ),
    ];

enum RelatedType {
  jaccard,
  cosine,
  overlap,
  frequency,
}
