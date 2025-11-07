// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'pool_category.dart';
import 'pool_order.dart';

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
  }) => DanbooruPool(
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
  final List<int>? postIds;
  final DanbooruPoolCategory? category;
  final String? description;
  final PoolPostCount? postCount;
  final PoolName? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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

typedef PoolName = String;
typedef PoolPostCount = int;
typedef PoolId = int;

abstract class PoolRepository {
  Future<List<DanbooruPool>> getPools(
    int page, {
    DanbooruPoolCategory? category,
    DanbooruPoolOrder? order,
    String? name,
    String? description,
  });
  Future<List<DanbooruPool>> getPoolsByPostId(int postId);
}
