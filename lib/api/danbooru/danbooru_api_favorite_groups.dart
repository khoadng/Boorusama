// Package imports:
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiFavoriteGroups {
  @GET('/favorite_groups.json')
  Future<HttpResponse> getFavoriteGroups({
    @Query('page') int? page,
    @Query('search[name_contains]') String? namePattern,
    @Query('search[creator_name]') String? creatorName,
    @Query('only') String? only,
    @Query('limit') int? limit,
  });

  @POST('/favorite_groups.json')
  Future<HttpResponse> postFavoriteGroups({
    @Query('favorite_group[name]') String? name,
    @Query('favorite_group[post_ids_string]') String? postIdsString,
    @Query('favorite_group[is_private]') bool? isPrivate,
  });

  @PATCH('/favorite_groups/{groupId}.json')
  Future<HttpResponse> patchFavoriteGroups(
    @Path() int groupId, {
    @Query('favorite_group[name]') String? name,
    @Query('favorite_group[post_ids_string]') String? postIdsString,
    @Query('favorite_group[is_private]') bool? isPrivate,
  });

  @DELETE('/favorite_groups/{groupId}.json')
  Future<HttpResponse> deleteFavoriteGroup(
    @Path() int groupId,
  );
}
