// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/tags/categories/tag_category.dart';

class E621Tag extends Equatable {
  const E621Tag({
    required this.id,
    required this.name,
    required this.postCount,
    required this.relatedTags,
    required this.relatedTagsUpdatedAt,
    required this.category,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });
  final int id;
  final String name;
  final int postCount;
  final List<E621RelatedTag> relatedTags;
  final DateTime relatedTagsUpdatedAt;
  final TagCategory category;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object> get props => [
    id,
    name,
    postCount,
    relatedTags,
    relatedTagsUpdatedAt,
    category,
    isLocked,
    createdAt,
    updatedAt,
  ];
}

class E621RelatedTag extends Equatable {
  const E621RelatedTag({
    required this.tag,
    required this.score,
  });
  final String tag;
  final double score;

  @override
  List<Object> get props => [tag, score];
}

abstract interface class E621TagRepository {
  Future<List<E621Tag>> getTagsWithWildcard(
    String tag, {
    TagSortOrder order = TagSortOrder.count,
  });
}
