// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'moebooru_api.g.dart';

@RestApi()
abstract class MoebooruApi {
  factory MoebooruApi(Dio dio, {String baseUrl}) = _MoebooruApi;

  @GET('/post.json')
  Future<HttpResponse> getPosts(
    @Query('login') String? login,
    @Query('password_hash') String? passwordHash,
    @Query('page') int page,
    @Query('tags') String tags,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
