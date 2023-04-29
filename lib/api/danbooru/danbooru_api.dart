// ignore_for_file: avoid_positional_boolean_parameters

// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'danbooru_api.g.dart';

@RestApi()
abstract class DanbooruApi {
  factory DanbooruApi(Dio dio, {String baseUrl}) = _DanbooruApi;

  @POST('/favorites')
  Future<HttpResponse> addToFavorites(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('post_id') int postId,
  );

  @POST('/favorites/{postId}')
  @FormUrlEncoded()
  Future<HttpResponse> removeFromFavorites(
    @Path() int postId,
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Field('_method') String method,
  );

  @GET('/favorites.json')
  Future<HttpResponse> filterFavoritesFromUserId(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
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

  @GET('/comments.json')
  Future<HttpResponse> getComments(
    @Query('search[post_id]') int postId,
    @Query('limit') int limit, {
    @Query('only') String? only,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/artists.json')
  Future<HttpResponse> getArtist(
    @Query('search[name]') String name, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST('/comments.json')
  @FormUrlEncoded()
  Future<HttpResponse> postComment(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Field('comment[post_id]') int postId,
    @Field('comment[body]') String content,
    @Field('comment[do_not_bump_post]') bool doNotBumpPost,
  );

  @PUT('/comments/{commentId}.json')
  @FormUrlEncoded()
  Future<HttpResponse> updateComment(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int commentId,
    @Field('comment[body]') String content,
  );

  @DELETE('/comments/{commentId}.json')
  @FormUrlEncoded()
  Future<HttpResponse> deleteComment(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int commentId,
  );

  @GET('/comment_votes.json')
  Future<HttpResponse> getCommentVotes(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('search[comment_id]') String commentIdsComma,
    @Query('search[is_deleted]') bool isDeleted,
  );

  @POST('/comments/{commentId}/votes.json')
  Future<HttpResponse> voteComment(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int commentId,
    @Query('score') int score,
  );

  @DELETE('/comment_votes/{commentId}.json')
  Future<HttpResponse> removeVoteComment(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int commentId,
  );

  @GET('/notes.json')
  Future<HttpResponse> getNotes(
    @Query('search[post_id]') int postId,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/profile.json')
  Future<HttpResponse> getProfile(
    @Query('login') String? login,
    @Query('api_key') String? apiKey, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/posts.json')
  Future<HttpResponse> getPosts(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('tags') String tags,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/posts/{postId}')
  Future<HttpResponse> getPost(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int postId,
  );

  @GET('/counts/posts.json')
  Future<HttpResponse> countPosts(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('tags') String tags,
  );

  @GET('/artist_commentaries.json')
  Future<HttpResponse> getArtistCommentary(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('search[post_id]') int postId, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/explore/posts/popular.json')
  Future<HttpResponse> getPopularPosts(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('date') String date,
    @Query('scale') String scale,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/explore/posts/viewed.json')
  Future<HttpResponse> getMostViewedPosts(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('date') String date,
  );

  @GET('/explore/posts/searches.json')
  Future<HttpResponse> getPopularSearchByDate(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('date') String date,
  );

  @GET('/tags.json')
  Future<HttpResponse> getTagsByNamePattern(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('search[hide_empty]') String hideEmpty,
    @Query('search[name_or_alias_matches]') String stringPattern,
    @Query('search[order]') String order,
    @Query('limit') int limit,
  );

  @GET('/tags.json')
  Future<HttpResponse> getTagsByNameComma(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('search[hide_empty]') String hideEmpty,
    @Query('search[name_comma]') String stringComma,
    @Query('search[order]') String order,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/users.json')
  Future<HttpResponse> getUsersByIdStringComma(
    @Query('search[id]') String idComma,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/users/{id}.json')
  Future<HttpResponse> getUserById(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int id,
  );

  @PATCH('/users/{id}.json')
  @FormUrlEncoded()
  Future<HttpResponse> setBlacklistedTags(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int id,
    @Field('user[blacklisted_tags]') String blacklistedTags, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/wiki_pages/{subject}.json')
  Future<HttpResponse> getWiki(
    @Path() String subject, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/pools.json')
  Future<HttpResponse> getPools(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('limit') int limit, {
    @Query('search[category]') String? category,
    @Query('search[order]') String? order,
    @Query('search[name_matches]') String? name,
    @Query('search[description_matches]') String? description,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/pools.json')
  Future<HttpResponse> getPoolsFromPostId(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('search[post_ids_include_all]') int postId,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/pools.json')
  Future<HttpResponse> getPoolsFromPostIds(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('search[post_ids_include_any]') String postIds,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/autocomplete.json')
  Future<HttpResponse> autocomplete(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('search[query]') String query,
    @Query('search[type]') String type,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/related_tag.json')
  Future<HttpResponse> getRelatedTag(
    @Query('search[query]') String query, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST('/posts/{postId}/votes.json')
  Future<HttpResponse> votePost(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int postId,
    @Query('score') int score,
  );
  @DELETE('/posts/{postId}/votes.json')
  Future<HttpResponse> removeVotePost(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int postId,
  );

  @GET('/post_votes.json')
  Future<HttpResponse> getPostVotes(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('search[post_id]') String postIdsComma,
    @Query('search[user_id]') String? userId,
    @Query('search[is_deleted]') bool isDeleted,
    @Query('limit') int limit,
  );

  @PUT('/posts/{postId}.json')
  @FormUrlEncoded()
  Future<HttpResponse> putTag(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int postId,
    @Body() Map<String, dynamic> map,
  );

  @GET('/saved_searches.json')
  Future<HttpResponse> getSavedSearches(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/saved_searches.json')
  @FormUrlEncoded()
  Future<HttpResponse> postSavedSearch(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Body() Map<String, dynamic> map,
  );

  @PATCH('/saved_searches/{id}.json')
  @FormUrlEncoded()
  Future<HttpResponse> patchSavedSearch(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int id,
    @Body() Map<String, dynamic> map,
  );

  @DELETE('/saved_searches/{id}.json')
  Future<HttpResponse> deleteSavedSearch(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int id,
  );

  @GET('/favorite_groups.json')
  Future<HttpResponse> getFavoriteGroups(
    @Query('login') String? login,
    @Query('api_key') String? apiKey, {
    @Query('page') int? page,
    @Query('search[name_contains]') String? namePattern,
    @Query('search[creator_name]') String? creatorName,
    @Query('only') String? only,
    @Query('limit') int? limit,
  });

  @POST('/favorite_groups.json')
  Future<HttpResponse> postFavoriteGroups(
    @Query('login') String? login,
    @Query('api_key') String? apiKey, {
    @Query('favorite_group[name]') String? name,
    @Query('favorite_group[post_ids_string]') String? postIdsString,
    @Query('favorite_group[is_private]') bool? isPrivate,
  });

  @PATCH('/favorite_groups/{groupId}.json')
  Future<HttpResponse> patchFavoriteGroups(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int groupId, {
    @Query('favorite_group[name]') String? name,
    @Query('favorite_group[post_ids_string]') String? postIdsString,
    @Query('favorite_group[is_private]') bool? isPrivate,
  });

  @DELETE('/favorite_groups/{groupId}.json')
  Future<HttpResponse> deleteFavoriteGroup(
    @Query('login') String? login,
    @Query('api_key') String? apiKey,
    @Path() int groupId,
  );
}
