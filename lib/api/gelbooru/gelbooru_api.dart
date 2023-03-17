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
}
