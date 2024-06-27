// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'tag_category.dart';

typedef PostCount = int;

class Tag extends Equatable {
  const Tag({
    required this.name,
    required this.category,
    required this.postCount,
  });

  const Tag.noCount({
    required this.name,
    required this.category,
  }) : postCount = 0;

  factory Tag.empty() => const Tag(
        name: '',
        category: TagCategory.invalid_,
        postCount: 0,
      );

  Tag copyWith(
    String? name,
    TagCategory? category,
    PostCount? postCount,
  ) =>
      Tag(
        name: name ?? this.name,
        category: category ?? this.category,
        postCount: postCount ?? this.postCount,
      );

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        name: json['name'],
        category: intToTagCategory(json['category'] as int),
        postCount: json['postCount'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.index,
        'postCount': postCount,
      };

  final String name;
  final TagCategory category;
  final PostCount postCount;

  String get displayName => name.replaceAll('_', ' ');
  String get rawName => name;

  @override
  String toString() => '$rawName ($postCount)';

  @override
  List<Object?> get props => [name, category, postCount];
}

extension TagX on Tag {
  bool get hasPost => postCount > 0;
}
