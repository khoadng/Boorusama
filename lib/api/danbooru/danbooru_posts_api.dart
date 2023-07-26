// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruPostsApi {
  @GET('/posts.json')
  Future<HttpResponse> getPosts(
    @Query('page') int page,
    @Query('tags') String tags,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST('/posts/{postId}/votes.json')
  Future<HttpResponse> votePost(
    @Path() int postId,
    @Query('score') int score,
  );
  @DELETE('/posts/{postId}/votes.json')
  Future<HttpResponse> removeVotePost(
    @Path() int postId,
  );

  @GET('/post_votes.json')
  Future<HttpResponse> getPostVotes(
    @Query('page') int page,
    @Query('search[post_id]') String postIdsComma,
    @Query('search[user_id]') String? userId,
    @Query('search[is_deleted]') bool isDeleted,
    @Query('limit') int limit,
  );

  @PUT('/posts/{postId}.json')
  @FormUrlEncoded()
  Future<HttpResponse> putTag(
    @Path() int postId,
    @Body() Map<String, dynamic> map,
  );
}
