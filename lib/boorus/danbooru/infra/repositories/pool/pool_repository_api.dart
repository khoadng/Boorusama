// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Pool> parsePool(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PoolDto.fromJson(item),
    ).map(poolDtoToPool).toList();

class PoolRepositoryApi implements PoolRepository {
  PoolRepositoryApi(
    this._api,
    this._currentUserBooruRepository,
  );

  final DanbooruApi _api;
  final CurrentBooruConfigRepository _currentUserBooruRepository;
  final _limit = 20;

  @override
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) =>
      _currentUserBooruRepository.get().then((booruConfig) => _api
          .getPools(
            booruConfig?.login,
            booruConfig?.apiKey,
            page,
            _limit,
            category: category?.toString(),
            order: order?.key,
            name: name,
            description: description,
          )
          .then(parsePool));

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) =>
      _currentUserBooruRepository.get().then((booruConfig) => _api
          .getPoolsFromPostId(
            booruConfig?.login,
            booruConfig?.apiKey,
            postId,
            _limit,
          )
          .then(parsePool));

  @override
  Future<List<Pool>> getPoolsByPostIds(List<int> postIds) {
    if (postIds.isEmpty) return Future.value([]);

    return _currentUserBooruRepository.get().then((booruConfig) => _api
        .getPoolsFromPostIds(
          booruConfig?.login,
          booruConfig?.apiKey,
          postIds.join(' '),
          _limit,
        )
        .then(parsePool));
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
