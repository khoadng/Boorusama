// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/http/http.dart';

List<Pool> parsePool(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => PoolDto.fromJson(item),
    ).map(poolDtoToPool).toList();

class PoolRepositoryApi
    with RequestDeduplicator<List<Pool>>
    implements PoolRepository {
  PoolRepositoryApi(
    this._api,
  );

  final DanbooruApi _api;
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
      '$page-${category?.toString()}-${order?.key}-$name-$description';

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
      () => _api
          .getPools(
            page,
            _limit,
            category: category?.toString(),
            order: order?.key,
            name: name,
            description: description,
          )
          .then(parsePool),
    );

    _cache.set(key, pools);

    return pools;
  }

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) => _api
      .getPoolsFromPostId(
        postId,
        _limit,
      )
      .then(parsePool);

  @override
  Future<List<Pool>> getPoolsByPostIds(List<int> postIds) {
    if (postIds.isEmpty) return Future.value([]);

    return _api
        .getPoolsFromPostIds(
          postIds.join(' '),
          _limit,
        )
        .then(parsePool);
  }
}

Pool poolDtoToPool(PoolDto dto) => Pool(
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
