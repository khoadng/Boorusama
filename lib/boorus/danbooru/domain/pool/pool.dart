// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:equatable/equatable.dart';

@immutable
class Pool {
  Pool({
    required this.id,
    required this.postIds,
    required this.category,
    required this.description,
    required this.postCount,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final PoolId id;
  final List<int> postIds;
  final PoolCategory category;
  final PoolDescription description;
  final PoolPostCount postCount;
  final PoolName name;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum PoolCategory {
  unknown,
  collection,
  series,
}

class PoolName extends Equatable {
  PoolName(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class PoolDescription extends Equatable {
  PoolDescription(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class PoolPostCount extends Equatable {
  PoolPostCount(this.value);
  final int value;

  @override
  List<Object?> get props => [value];
}

class PoolId extends Equatable {
  PoolId(this.value);
  final int value;

  @override
  List<Object?> get props => [value];
}

extension PoolX on Pool {
  int? get postCoverId => postIds.isEmpty ? null : postIds.first;
}
