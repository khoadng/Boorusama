// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruPoolsApi {
  @GET('/pools.json')
  Future<HttpResponse> getPools(
    @Query('page') int page,
    @Query('limit') int limit, {
    @Query('search[category]') String? category,
    @Query('search[order]') String? order,
    @Query('search[name_matches]') String? name,
    @Query('search[description_matches]') String? description,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/pools.json')
  Future<HttpResponse> getPoolsFromPostId(
    @Query('search[post_ids_include_all]') int postId,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/pools.json')
  Future<HttpResponse> getPoolsFromPostIds(
    @Query('search[post_ids_include_any]') String postIds,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
