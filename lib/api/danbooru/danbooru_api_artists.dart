// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiArtists {
  @GET('/artists.json')
  Future<HttpResponse> getArtist(
    @Query('search[name]') String name,
    @Query('only') String only, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/artist_commentaries.json')
  Future<HttpResponse> getArtistCommentary(
    @Query('search[post_id]') int postId, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/artist_urls.json')
  Future<HttpResponse> getArtistUrls(
    @Query('search[artist_id]') int artistId, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
