// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'gelbooru_v0.2_api.g.dart';

@RestApi()
abstract class GelbooruV0dot2Api {
  factory GelbooruV0dot2Api(Dio dio, {String baseUrl}) = _GelbooruV0dot2Api;

  @GET('/index.php')
  Future<HttpResponse> getPosts(
    @Query('api_key') String? apiKey,
    @Query('user_id') String? userId,
    @Query('page') String page,
    @Query('s') String s,
    @Query('q') String q,
    @Query('tags') String tags,
    @Query('json') String json,
    @Query('pid') String pid, {
    @Query('limit') int? limit,
  });

  @GET('/autocomplete.php')
  Future<HttpResponse> autocomplete(
    @Query('api_key') String? apiKey,
    @Query('user_id') String? userId,
    @Query('q') String q, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
