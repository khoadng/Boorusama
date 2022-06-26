// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';

class RelatedTag extends Equatable {
  const RelatedTag({
    required this.query,
    required this.tags,
  });

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
  });

  final TagCategory category;
  final String tag;

  @override
  List<Object?> get props => [tag, category];
}
