// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/pool/pool.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class PoolDescriptionCacher implements PoolDescriptionRepository {
  const PoolDescriptionCacher({
    required this.cache,
    required this.repo,
  });

  final Cacher<int, String> cache;
  final PoolDescriptionRepository repo;

  @override
  Future<String> getDescription(int poolId) async {
    final item = cache.get(poolId);

    if (item != null) return item;

    final fresh = await repo.getDescription(poolId);
    await cache.put(poolId, fresh);

    return fresh;
  }
}

class PoolRepositoryCacher implements PoolRepository {
  const PoolRepositoryCacher({
    required this.cache,
    required this.repo,
  });

  final Cacher<int, List<Pool>> cache;
  final PoolRepository repo;

  @override
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) =>
      repo.getPools(
        page,
        category: category,
        order: order,
        name: name,
        description: description,
      );

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) async {
    final item = cache.get(postId);

    if (item != null) return item;

    final fresh = await repo.getPoolsByPostId(postId);
    await cache.put(postId, fresh);

    return fresh;
  }
}
