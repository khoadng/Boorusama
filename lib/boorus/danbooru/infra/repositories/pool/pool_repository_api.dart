// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/cache_mixin.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/core/infra/networks/request_deduplicator_mixin.dart';

List<Pool> parsePool(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PoolDto.fromJson(item),
    ).map(poolDtoToPool).toList();

class PoolRepositoryApi
    with RequestDeduplicator<List<Pool>>
    implements PoolRepository {
  PoolRepositoryApi(
    this._api,
    this.booruConfig,
  );

  final DanbooruApi _api;
  final BooruConfig booruConfig;
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
            booruConfig.login,
            booruConfig.apiKey,
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
        booruConfig.login,
        booruConfig.apiKey,
        postId,
        _limit,
      )
      .then(parsePool);

  @override
  Future<List<Pool>> getPoolsByPostIds(List<int> postIds) {
    if (postIds.isEmpty) return Future.value([]);

    return _api
        .getPoolsFromPostIds(
          booruConfig.login,
          booruConfig.apiKey,
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
