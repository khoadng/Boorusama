// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';

class RelatedTag extends Equatable {
  const RelatedTag({
    required this.query,
    required this.tags,
  });

  const RelatedTag.empty()
      : query = '',
        tags = const [];

  final String query;
  final List<RelatedTagItem> tags;

  RelatedTag copyWith({
    List<RelatedTagItem>? tags,
    String? query,
  }) =>
      RelatedTag(
        query: query ?? this.query,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [query, tags];
}

class RelatedTagItem extends Equatable {
  const RelatedTagItem({
    required this.tag,
    required this.category,
    required this.jaccardSimilarity,
    required this.cosineSimilarity,
    required this.overlapCoefficient,
    required this.postCount,
  });

  final TagCategory category;
  final String tag;
  final double jaccardSimilarity;
  final double cosineSimilarity;
  final double overlapCoefficient;
  final int postCount;

  @override
  List<Object?> get props => [
        tag,
        category,
        jaccardSimilarity,
        cosineSimilarity,
        overlapCoefficient,
      ];
}
