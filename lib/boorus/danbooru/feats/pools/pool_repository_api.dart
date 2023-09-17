// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/http/http.dart';

class PoolRepositoryApi
    with RequestDeduplicator<List<Pool>>
    implements PoolRepository {
  PoolRepositoryApi(
    this.client,
  );

  final DanbooruClient client;
  final _cache = Cache<List<Pool>>(
    maxCapacity: 10,
    staleDuration: const Duration(seconds: 10),
  );
  final _limit = 20;

  String _buildKey(
    int page,
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  ) =>
      '$page-${category?.toString()}-${order?.name}-$name-$description';

  @override
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) async {
    final key = _buildKey(page, category, order, name, description);

    final cachedPools = _cache.get(key);
    if (cachedPools != null) {
      return Future.value(cachedPools);
    }

    final pools = await deduplicate(
      key,
      () => client
          .getPools(
            page: page,
            limit: _limit,
            category: switch (category) {
              PoolCategory.collection => danbooru.PoolCategory.collection,
              PoolCategory.series => danbooru.PoolCategory.series,
              PoolCategory.unknown => null,
              null => null,
            },
            order: switch (order) {
              PoolOrder.newest => danbooru.PoolOrder.createdAt,
              PoolOrder.latest => danbooru.PoolOrder.updatedAt,
              PoolOrder.postCount => danbooru.PoolOrder.postCount,
              PoolOrder.name => danbooru.PoolOrder.name,
              null => null,
            },
            name: name,
            description: description,
          )
          .then((value) => value.map(poolDtoToPool).toList()),
    );

    _cache.set(key, pools);

    return pools;
  }

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) => client
      .getPoolsFromPostId(
        postId: postId,
        limit: _limit,
      )
      .then((value) => value.map(poolDtoToPool).toList());

  @override
  Future<List<Pool>> getPoolsByPostIds(List<int> postIds) {
    if (postIds.isEmpty) return Future.value([]);

    return client
        .getPoolsFromPostIds(
          postIds: postIds,
          limit: _limit,
        )
        .then((value) => value.map(poolDtoToPool).toList());
  }
}

Pool poolDtoToPool(danbooru.PoolDto dto) => Pool(
      id: dto.id!,
      postIds: dto.postIds!,
      category: stringToPoolCategory(dto.category),
      description: dto.description!,
      postCount: dto.postCount!,
      name: dto.name!,
      createdAt: dto.createdAt!,
      updatedAt: dto.updatedAt!,
    );

PoolCategory stringToPoolCategory(String? value) => switch (value) {
      'collection' => PoolCategory.collection,
      'series' => PoolCategory.series,
      _ => PoolCategory.unknown
    };
