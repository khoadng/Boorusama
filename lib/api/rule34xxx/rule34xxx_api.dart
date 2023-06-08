// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'rule34xxx_api.g.dart';

@RestApi()
abstract class Rule34xxxApi {
  factory Rule34xxxApi(Dio dio, {String baseUrl}) = _Rule34xxxApi;

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

  @GET('/public/autocomplete.php')
  Future<HttpResponse> autocomplete(
    @Query('api_key') String? apiKey,
    @Query('user_id') String? userId,
    @Query('q') String q, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
