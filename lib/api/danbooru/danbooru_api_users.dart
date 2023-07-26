// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiUsers {
  @GET('/users.json')
  Future<HttpResponse> getUsersByIdStringComma(
    @Query('search[id]') String idComma,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/users/{id}.json')
  Future<HttpResponse> getUserById(
    @Path() int id,
  );

  @PATCH('/users/{id}.json')
  @FormUrlEncoded()
  Future<HttpResponse> setBlacklistedTags(
    @Path() int id,
    @Field('user[blacklisted_tags]') String blacklistedTags, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
