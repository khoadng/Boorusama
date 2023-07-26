// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruCommentsApi {
  @GET('/comments.json')
  Future<HttpResponse> getComments(
    @Query('search[post_id]') int postId,
    @Query('limit') int limit, {
    @Query('only') String? only,
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST('/comments.json')
  @FormUrlEncoded()
  Future<HttpResponse> postComment(
    @Field('comment[post_id]') int postId,
    @Field('comment[body]') String content,
    @Field('comment[do_not_bump_post]') bool doNotBumpPost,
  );

  @PUT('/comments/{commentId}.json')
  @FormUrlEncoded()
  Future<HttpResponse> updateComment(
    @Path() int commentId,
    @Field('comment[body]') String content,
  );

  @DELETE('/comments/{commentId}.json')
  @FormUrlEncoded()
  Future<HttpResponse> deleteComment(
    @Path() int commentId,
  );

  @GET('/comment_votes.json')
  Future<HttpResponse> getCommentVotes(
    @Query('search[comment_id]') String commentIdsComma,
    @Query('search[is_deleted]') bool isDeleted,
  );

  @POST('/comments/{commentId}/votes.json')
  Future<HttpResponse> voteComment(
    @Path() int commentId,
    @Query('score') int score,
  );

  @DELETE('/comment_votes/{commentId}.json')
  Future<HttpResponse> removeVoteComment(
    @Path() int commentId,
  );
}
