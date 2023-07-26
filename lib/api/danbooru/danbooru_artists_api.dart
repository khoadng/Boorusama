// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruArtistsApi {
  @GET('/artists.json')
  Future<HttpResponse> getArtist(
    @Query('search[name]') String name, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/artist_commentaries.json')
  Future<HttpResponse> getArtistCommentary(
    @Query('search[post_id]') int postId, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
