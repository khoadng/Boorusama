// ignore_for_file: avoid_positional_boolean_parameters

// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'e621_api.g.dart';

@RestApi()
abstract class E621Api {
  factory E621Api(
    Dio dio, {
    String baseUrl,
  }) = _E621Api;

  @POST('/favorites.json')
  Future<HttpResponse> addToFavorites(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('post_id') int postId,
  );

  @DELETE('/favorites/{postId}.json')
  Future<HttpResponse> removeFromFavorites(
    @Path() int postId,
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
  );

  @GET('/comments.json')
  Future<HttpResponse> getComments(
    @Query('group_by') String groupBy,
    @Query('search[post_id]') int postId,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/artists.json')
  Future<HttpResponse> getArtists(
    @Query('search[name]') String name, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/artists/{nameOrId}.json')
  Future<HttpResponse> getArtist(
    @Path() String nameOrId, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/posts.json')
  Future<HttpResponse> getPosts(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('tags') String tags,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/popular.json')
  Future<HttpResponse> getPopularPosts(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('date') String date,
    @Query('scale') String scale,
  );

  @GET('/tags.json')
  Future<HttpResponse> getTagsByNamePattern(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('search[hide_empty]') String hideEmpty,
    @Query('search[name_matches]') String stringPattern,
    @Query('search[order]') String order,
    @Query('limit') int limit,
  );
}
