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

  factory Tag.empty() => Tag(
        name: '',
        category: TagCategory.unknown(),
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
        category: TagCategory.fromLegacyId(json['category']),
        postCount: json['postCount'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.id,
        'postCount': postCount,
      };

  final String name;
  final TagCategory category;
  final PostCount postCount;

  @override
  String toString() => '$rawName ($postCount)';

  @override
  List<Object?> get props => [name, category, postCount];
}

extension TagX on Tag {
  String get displayName => name.replaceAll('_', ' ');
  String get rawName => name;
}
