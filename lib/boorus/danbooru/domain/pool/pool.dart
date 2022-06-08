// Flutter imports:
import 'package:flutter/cupertino.dart';

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
  });

  final int id;
  final List<int> postIds;
  final PoolCategory category;
  final String description;
  final PoolPostCount postCount;
  final PoolName name;
  final DateTime createdAt;
}

enum PoolCategory {
  unknown,
  collection,
  series,
}

class PoolName {
  PoolName(this.value);
  final String value;
}

class PoolPostCount {
  PoolPostCount(this.value);
  final int value;
}

extension PoolX on Pool {
  int? get postCoverId => postIds.isEmpty ? null : postIds.first;
}
