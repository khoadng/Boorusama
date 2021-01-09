import 'package:boorusama/infrastructure/apis/i_api.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'danbooru_api.g.dart';

@RestApi()
abstract class DanbooruApi implements IApi {
  factory DanbooruApi(Dio dio, {String baseUrl}) = _DanbooruApi;

  @POST("/favorites")
  @override
  Future<HttpResponse> addToFavorites(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("post_id") int postId,
  );

  @POST("/favorites/{postId}")
  @FormUrlEncoded()
  @override
  Future<HttpResponse> removeFromFavorites(
    @Path() int postId,
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Field("_method") String method,
  );

  @GET("/comments.json")
  @override
  Future<HttpResponse> getComments(
    @Query("search[post_id]") int postId,
    @Query("limit") int limit,
  );

  @POST("/comments.json")
  @FormUrlEncoded()
  @override
  Future<HttpResponse> postComment(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Field("comment[post_id]") int postId,
    @Field("comment[body]") String content,
    @Field("comment[do_not_bump_post]") bool doNotBumpPost,
  );

  @PUT("/comments/{commentId}.json")
  @FormUrlEncoded()
  @override
  Future<HttpResponse> updateComment(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Path() int commentId,
    @Field("comment[body]") String content,
  );

  @GET("/posts/{postId}")
  @override
  Future<HttpResponse> getNotes(
    @Path() int postId,
  );
}
