// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'gelbooru_api.g.dart';

@RestApi()
abstract class GelbooruApi {
  factory GelbooruApi(Dio dio, {String baseUrl}) = _GelbooruApi;

  @GET('/index.php')
  Future<HttpResponse> getPosts(
    @Query('api_key') String? apiKey,
    @Query('user_id') String? userId,
    @Query('page') String page,
    @Query('s') String s,
    @Query('q') String q,
    @Query('tags') String tags,
    @Query('json') String json,
    @Query('pid') String pid,
  );

  @GET('/index.php')
  Future<HttpResponse> getTags(
    @Query('api_key') String? apiKey,
    @Query('user_id') String? userId,
    @Query('page') String page,
    @Query('s') String s,
    @Query('q') String q,
    @Query('names') String names,
    @Query('json') String json,
    @Query('pid') String pid,
  );

  @GET('/index.php')
  Future<HttpResponse> autocomplete(
    @Query('api_key') String? apiKey,
    @Query('user_id') String? userId,
    @Query('page') String page,
    @Query('type') String type,
    @Query('limit') int limit,
    @Query('term') String term, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/index.php')
  Future<HttpResponse> getComments(
    @Query('api_key') String? apiKey,
    @Query('user_id') String? userId,
    @Query('page') String page,
    @Query('s') String s,
    @Query('q') String q,
    @Query('post_id') int postId, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
