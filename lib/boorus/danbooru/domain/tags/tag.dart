// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'post_count_type.dart';
import 'tag_category.dart';

typedef PostCount = int;

class Tag extends Equatable {
  const Tag({
    required this.name,
    required this.category,
    required this.postCount,
  });

  factory Tag.empty() => Tag(
        name: '',
        category: TagCategory.invalid_,
        postCount: PostCountType(0),
      );

  final String name;
  final TagCategory category;
  final PostCountType postCount;

  String get displayName => name.replaceAll('_', ' ');
  String get rawName => name;

  @override
  String toString() => '$rawName (${postCount.toString()})';

  @override
  List<Object?> get props => [name, category, postCount];
}
