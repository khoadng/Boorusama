// Dart imports:
import 'dart:async';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';

class PoolCacher implements PoolRepository {
  final PoolRepository _poolRepository;

  final Map<String, List<Pool>> _cache = {};

  PoolCacher(this._poolRepository);

  @override
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) =>
      _poolRepository.getPools(
        page,
        category: category,
        order: order,
        name: name,
        description: description,
      );

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) async {
    String cacheKey = 'postId:$postId';

    if (!_cache.containsKey(cacheKey)) {
      _cache[cacheKey] = await _poolRepository.getPoolsByPostId(postId);
    }

    return _cache[cacheKey]!;
  }

  @override
  Future<List<Pool>> getPoolsByPostIds(List<int> postIds) async {
    String cacheKey = 'postIds:${postIds.join(',')}';

    if (!_cache.containsKey(cacheKey)) {
      _cache[cacheKey] = await _poolRepository.getPoolsByPostIds(postIds);
    }

    return _cache[cacheKey]!;
  }
}
