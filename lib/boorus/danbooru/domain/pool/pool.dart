// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:equatable/equatable.dart';

@immutable
class Pool {
  const Pool({
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
  const PoolName(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class PoolDescription extends Equatable {
  const PoolDescription(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class PoolPostCount extends Equatable {
  const PoolPostCount(this.value);
  final int value;

  @override
  List<Object?> get props => [value];
}

class PoolId extends Equatable {
  const PoolId(this.value);
  final int value;

  @override
  List<Object?> get props => [value];
}
