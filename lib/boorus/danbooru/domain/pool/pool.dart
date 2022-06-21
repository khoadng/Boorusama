// Flutter imports:
import 'package:flutter/cupertino.dart';

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

enum PoolOrder {
  latest('updated_at'),
  newest('created_at'),
  postCount('post_count'),
  name('name');

  const PoolOrder(this.key);

  final String key;
}

enum PoolCategory {
  unknown,
  collection,
  series;

  @override
  String toString() => name;
}

typedef PoolName = String;
typedef PoolDescription = String;
typedef PoolPostCount = int;
typedef PoolId = int;
