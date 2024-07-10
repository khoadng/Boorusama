// Package imports:
import 'package:equatable/equatable.dart';

class DanbooruPool extends Equatable {
  const DanbooruPool({
    required this.id,
    required this.postIds,
    required this.category,
    required this.description,
    required this.postCount,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DanbooruPool.empty() => DanbooruPool(
        id: -1,
        postIds: const [],
        category: DanbooruPoolCategory.unknown,
        description: '',
        postCount: 0,
        name: '',
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
      );

  DanbooruPool copyWith({
    PoolId? id,
    List<int>? postIds,
  }) =>
      DanbooruPool(
        id: id ?? this.id,
        postIds: postIds ?? this.postIds,
        category: category,
        description: description,
        postCount: postCount,
        name: name,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  final PoolId id;
  final List<int> postIds;
  final DanbooruPoolCategory category;
  final PoolDescription description;
  final PoolPostCount postCount;
  final PoolName name;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        postIds,
        category,
        description,
        postCount,
        name,
        createdAt,
        updatedAt,
      ];
}

enum DanbooruPoolOrder {
  latest,
  newest,
  postCount,
  name,
}

typedef PoolName = String;
typedef PoolDescription = String;
typedef PoolPostCount = int;
typedef PoolId = int;

enum DanbooruPoolCategory {
  unknown,
  collection,
  series;
}

typedef PoolCover = ({
  PoolId id,
  String? url,
  double? aspectRatio,
});
