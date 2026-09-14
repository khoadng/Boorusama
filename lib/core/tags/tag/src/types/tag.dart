// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../posts/post/types.dart';
import '../../../categories/types.dart';

typedef PostCount = int;

class Tag extends Equatable {
  const Tag({
    required this.name,
    required this.category,
    required this.postCount,
    this.label,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    name: json['name'],
    category: TagCategory.fromLegacyId(json['category']),
    postCount: json['postCount'],
    label: json['label'] as String?,
  );

  const Tag.noCount({
    required this.name,
    required this.category,
    this.label,
  }) : postCount = 0;

  factory Tag.empty() => Tag(
    name: '',
    category: TagCategory.unknown(),
    postCount: 0,
  );

  Tag copyWith(
    String? name,
    TagCategory? category,
    PostCount? postCount, {
    String? label,
  }) => Tag(
    name: name ?? this.name,
    category: category ?? this.category,
    postCount: postCount ?? this.postCount,
    label: label ?? this.label,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category.id,
    'postCount': postCount,
    'label': ?label,
  };

  final String name;
  final String? label;
  final TagCategory category;
  final PostCount postCount;

  @override
  String toString() => '$name ($postCount)';

  @override
  List<Object?> get props => [name, label, category, postCount];
}

typedef TagFetcher = FutureOr<List<Tag>> Function(
  Post post,
  ExtractOptions options,
);

typedef TagFetcherBatch = FutureOr<List<Tag>> Function(
  List<Post> posts,
  ExtractOptions options,
);

class ExtractOptions {
  const ExtractOptions({
    this.fetchTagCount = false,
    this.cancelToken,
  });

  final bool fetchTagCount;
  final CancelToken? cancelToken;
}
