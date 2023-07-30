// Package imports:
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiFavorites {
  @POST('/favorites.json')
  Future<HttpResponse> addToFavorites(
    @Query('post_id') int postId,
  );

  @DELETE('/favorites/{postId}.json')
  Future<HttpResponse> removeFromFavorites(
    @Path() int postId,
  );

  @GET('/favorites.json')
  Future<HttpResponse> filterFavoritesFromUserId(
    @Query('search[post_id]') String postIdsString,
    @Query('search[user_id]') int userId,
    @Query('limit') int limit,
  );

  @GET('/posts/{postId}/favorites.json')
  Future<HttpResponse> getFavorites(
    @Path() int postId,
    @Query('page') int page,
    @Query('limit') int limit,
  );
}
