// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infra/apis/api.dart';

part 'danbooru_api.g.dart';

@RestApi()
abstract class DanbooruApi implements Api {
  factory DanbooruApi(Dio dio, {String baseUrl}) = _DanbooruApi;

  @POST('/favorites')
  @override
  Future<HttpResponse> addToFavorites(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('post_id') int postId,
  );

  @POST('/favorites/{postId}')
  @FormUrlEncoded()
  @override
  Future<HttpResponse> removeFromFavorites(
    @Path() int postId,
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Field('_method') String method,
  );

  @GET('/favorites.json')
  @override
  Future<HttpResponse> filterFavoritesFromUserId(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('search[post_id]') String postIdsString,
    @Query('search[user_id]') int userId,
    @Query('limit') int limit,
  );

  @GET('/comments.json')
  @override
  Future<HttpResponse> getComments(
    @Query('search[post_id]') int postId,
    @Query('limit') int limit, {
    @Query('only') String? only,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/artists.json')
  @override
  Future<HttpResponse> getArtist(
    @Query('search[name]') String name, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST('/comments.json')
  @FormUrlEncoded()
  @override
  Future<HttpResponse> postComment(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Field('comment[post_id]') int postId,
    @Field('comment[body]') String content,
    @Field('comment[do_not_bump_post]') bool doNotBumpPost,
  );

  @PUT('/comments/{commentId}.json')
  @FormUrlEncoded()
  @override
  Future<HttpResponse> updateComment(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int commentId,
    @Field('comment[body]') String content,
  );

  @DELETE('/comments/{commentId}.json')
  @FormUrlEncoded()
  @override
  Future<HttpResponse> deleteComment(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int commentId,
  );

  @GET('/comment_votes.json')
  @override
  Future<HttpResponse> getCommentVotes(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('search[comment_id]') String commentIdsComma,
    @Query('search[is_deleted]') bool isDeleted,
  );

  @POST('/comments/{commentId}/votes.json')
  @override
  Future<HttpResponse> voteComment(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int commentId,
    @Query('score') int score,
  );

  @DELETE('/comment_votes/{commentId}.json')
  @override
  Future<HttpResponse> removeVoteComment(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int commentId,
  );

  @GET('/notes.json')
  @override
  Future<HttpResponse> getNotes(
    @Query('search[post_id]') int postId, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/profile.json')
  @override
  Future<HttpResponse> getProfile(
    @Query('login') String login,
    @Query('api_key') String apiKey, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/posts.json')
  @override
  Future<HttpResponse> getPosts(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('page') int page,
    @Query('tags') String tags,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/posts/{postId}')
  @override
  Future<HttpResponse> getPost(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int postId,
  );

  @GET('/artist_commentaries.json')
  @override
  Future<HttpResponse> getArtistCommentary(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('search[post_id]') int postId, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/explore/posts/popular.json')
  @override
  Future<HttpResponse> getPopularPosts(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('date') String date,
    @Query('scale') String scale,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/explore/posts/curated.json')
  @override
  Future<HttpResponse> getCuratedPosts(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('date') String date,
    @Query('scale') String scale,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/explore/posts/viewed.json')
  @override
  Future<HttpResponse> getMostViewedPosts(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('date') String date,
  );

  @GET('/explore/posts/searches.json')
  @override
  Future<HttpResponse> getPopularSearchByDate(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('date') String date,
  );

  @GET('/tags.json')
  @override
  Future<HttpResponse> getTagsByNamePattern(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('page') int page,
    @Query('search[hide_empty]') String hideEmpty,
    @Query('search[name_or_alias_matches]') String stringPattern,
    @Query('search[order]') String order,
    @Query('limit') int limit,
  );

  @GET('/tags.json')
  @override
  Future<HttpResponse> getTagsByNameComma(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('page') int page,
    @Query('search[hide_empty]') String hideEmpty,
    @Query('search[name_comma]') String stringComma,
    @Query('search[order]') String order,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/users.json')
  @override
  Future<HttpResponse> getUsersByIdStringComma(
    @Query('search[id]') String idComma,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/users/{id}.json')
  @override
  Future<HttpResponse> getUserById(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int id,
  );

  @PATCH('/users/{id}.json')
  @FormUrlEncoded()
  @override
  Future<HttpResponse> setBlacklistedTags(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int id,
    @Field('user[blacklisted_tags]') String blacklistedTags, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/wiki_pages/{subject}.json')
  @override
  Future<HttpResponse> getWiki(
    @Path() String subject, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/pools.json')
  @override
  Future<HttpResponse> getPools(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('page') int page,
    @Query('limit') int limit, {
    @Query('search[category]') String? category,
    @Query('search[order]') String? order,
    @Query('search[name_matches]') String? name,
    @Query('search[description_matches]') String? description,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/pools.json')
  @override
  Future<HttpResponse> getPoolsFromPostId(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('search[post_ids_include_all]') int postId,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/autocomplete.json')
  @override
  Future<HttpResponse> autocomplete(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('search[query]') String query,
    @Query('search[type]') String type,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/related_tag.json')
  @override
  Future<HttpResponse> getRelatedTag(
    @Query('search[query]') String query, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST('/posts/{postId}/votes.json')
  @override
  Future<HttpResponse> votePost(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int postId,
    @Query('score') int score,
  );

  @DELETE('/posts/{postId}/votes.json')
  @override
  Future<HttpResponse> removeVotePost(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Path() int postId,
  );

  @GET('/post_votes.json')
  @override
  Future<HttpResponse> getPostVotes(
    @Query('login') String login,
    @Query('api_key') String apiKey,
    @Query('page') int page,
    @Query('search[post_id]') String postIdsComma,
    @Query('search[user_id]') String userId,
    @Query('search[is_deleted]') bool isDeleted,
  );
}
