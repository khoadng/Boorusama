// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruTagsApi {
  @GET('/tags.json')
  Future<HttpResponse> getTagsByNamePattern(
    @Query('page') int page,
    @Query('search[hide_empty]') String hideEmpty,
    @Query('search[name_or_alias_matches]') String stringPattern,
    @Query('search[order]') String order,
    @Query('limit') int limit,
  );

  @GET('/tags.json')
  Future<HttpResponse> getTagsByNameComma(
    @Query('page') int page,
    @Query('search[hide_empty]') String hideEmpty,
    @Query('search[name_comma]') String stringComma,
    @Query('search[order]') String order,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/related_tag.json')
  Future<HttpResponse> getRelatedTag(
    @Query('search[query]') String query,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
