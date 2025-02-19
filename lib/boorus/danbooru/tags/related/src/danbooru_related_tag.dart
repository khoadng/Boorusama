// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../core/tags/categories/tag_category.dart';
import '../../../../../core/tags/tag/tag.dart';

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

enum RelatedType {
  jaccard,
  cosine,
  overlap,
  frequency,
}
