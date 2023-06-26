// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'moebooru_api.g.dart';

@RestApi()
abstract class MoebooruApi {
  factory MoebooruApi(Dio dio, {String baseUrl}) = _MoebooruApi;

  @GET('/post.json')
  Future<HttpResponse> getPosts(
    @Query('login') String? login,
    @Query('password_hash') String? passwordHash,
    @Query('page') int page,
    @Query('tags') String tags,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/tag/summary.json')
  Future<HttpResponse> getTagSummary({
    @Query('login') String? login,
    @Query('password_hash') String? passwordHash,
    @CancelRequest() CancelToken? cancelToken,
  });

  // @GET('/post/popular_recent.json')
  // Future<HttpResponse> getPopularPostsRecent(
  //   @Query('login') String? login,
  //   @Query('password_hash') String? passwordHash,
  //   @Query('period') String period, {
  //   @CancelRequest() CancelToken? cancelToken,
  // });

  @GET('/post/popular_by_day.json')
  Future<HttpResponse> getPopularPostsByDay(
    @Query('login') String? login,
    @Query('password_hash') String? passwordHash,
    @Query('day') int day,
    @Query('month') int month,
    @Query('year') int year, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/post/popular_by_week.json')
  Future<HttpResponse> getPopularPostsByWeek(
    @Query('login') String? login,
    @Query('password_hash') String? passwordHash,
    @Query('day') int day,
    @Query('month') int month,
    @Query('year') int year, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/post/popular_by_month.json')
  Future<HttpResponse> getPopularPostsByMonth(
    @Query('login') String? login,
    @Query('password_hash') String? passwordHash,
    @Query('month') int month,
    @Query('year') int year, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/comment.json')
  Future<HttpResponse> getComments(
    @Query('login') String? login,
    @Query('password_hash') String? passwordHash,
    @Query('post_id') int postId, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
