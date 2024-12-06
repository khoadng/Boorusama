// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/foundation/caching/caching.dart';

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

enum PoolDetailsOrder {
  latest,
  oldest,
}

extension DanbooruPoolX on DanbooruPool {
  bool get isEmpty => id == -1;

  String get _query => 'pool:$id';

  String toSearchQuery() => _query;
}

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

class PoolRepositoryBuilder
    with SimpleCacheMixin<List<DanbooruPool>>
    implements PoolRepository {
  PoolRepositoryBuilder({
    required this.fetchMany,
    required this.fetchByPostId,
    int maxCapacity = 1000,
    Duration staleDuration = const Duration(minutes: 10),
  }) {
    cache = Cache(
      maxCapacity: maxCapacity,
      staleDuration: staleDuration,
    );
  }

  final Future<List<DanbooruPool>> Function(
    int page, {
    DanbooruPoolCategory? category,
    DanbooruPoolOrder? order,
    String? name,
    String? description,
  }) fetchMany;

  final Future<List<DanbooruPool>> Function(int postId) fetchByPostId;

  @override
  Future<List<DanbooruPool>> getPools(
    int page, {
    DanbooruPoolCategory? category,
    DanbooruPoolOrder? order,
    String? name,
    String? description,
  }) =>
      fetchMany(
        page,
        category: category,
        order: order,
        name: name,
        description: description,
      );

  @override
  Future<List<DanbooruPool>> getPoolsByPostId(int postId) => tryGet(
        'pool-by-post-$postId',
        orElse: () => fetchByPostId(postId),
      );

  @override
  late Cache<List<DanbooruPool>> cache;
}

abstract class PoolDescriptionRepository {
  Future<String> getDescription(int poolId);
}
