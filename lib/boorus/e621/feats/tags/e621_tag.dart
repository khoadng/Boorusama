// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'e621_tag_category.dart';

class E621Tag extends Equatable {
  final int id;
  final String name;
  final int postCount;
  final String relatedTags;
  final DateTime relatedTagsUpdatedAt;
  final E621TagCategory category;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

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
        updatedAt
      ];
}
