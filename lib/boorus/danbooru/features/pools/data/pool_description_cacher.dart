// Project imports:
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/foundation/caching/caching.dart';

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
