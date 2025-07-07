// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../posts/post/post.dart';
import '../../../categories/tag_category.dart';

typedef PostCount = int;

class Tag extends Equatable {
  const Tag({
    required this.name,
    required this.category,
    required this.postCount,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    name: json['name'],
    category: TagCategory.fromLegacyId(json['category']),
    postCount: json['postCount'],
  );

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
  ) => Tag(
    name: name ?? this.name,
    category: category ?? this.category,
    postCount: postCount ?? this.postCount,
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
  String toString() => '$name ($postCount)';

  @override
  List<Object?> get props => [name, category, postCount];
}

typedef TagFetcher =
    FutureOr<List<Tag>> Function(
      Post post,
      ExtractOptions options,
    );

class ExtractOptions {
  const ExtractOptions({
    this.fetchTagCount = false,
  });

  final bool fetchTagCount;
}
