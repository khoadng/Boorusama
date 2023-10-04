// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientPools {
  Dio get dio;

  Future<List<PoolDto>> getPools({
    int? page,
    int? limit,
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/pools.json',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (category != null) 'search[category]': category.name,
        if (order != null)
          'search[order]': switch (order) {
            PoolOrder.updatedAt => 'updated_at',
            PoolOrder.createdAt => 'created_at',
            PoolOrder.postCount => 'post_count',
            PoolOrder.name => 'name',
          },
        if (name != null) 'search[name_matches]': name,
        if (description != null) 'search[description_matches]': description,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => PoolDto.fromJson(item))
        .toList();
  }

  Future<List<PoolDto>> getPoolsFromPostId({
    required int postId,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/pools.json',
      queryParameters: {
        'search[post_ids_include_all]': postId,
        if (limit != null) 'limit': limit,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => PoolDto.fromJson(item))
        .toList();
  }

  Future<List<PoolDto>> getPoolsFromPostIds({
    required List<int> postIds,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    if (postIds.isEmpty) return [];

    final response = await dio.get(
      '/pools.json',
      queryParameters: {
        'search[post_ids_include_any]': postIds.join(' '),
        if (limit != null) 'limit': limit,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => PoolDto.fromJson(item))
        .toList();
  }

  Future<String> getPoolDescriptionHtml(int poolId) {
    return dio.get('/pools/$poolId').then((value) => value.data);
  }
}
