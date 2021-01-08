import 'package:boorusama/infrastructure/apis/i_api.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'danbooru_api.g.dart';

@RestApi()
abstract class DanbooruApi implements IApi {
  factory DanbooruApi(Dio dio, {String baseUrl}) = _DanbooruApi;

  @POST("/favorites")
  Future<HttpResponse> addToFavorites(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("post_id") int postId,
  );

  @POST("/favorites/{postId}")
  @FormUrlEncoded()
  Future<HttpResponse> removeFromFavorites(
    @Path() int postId,
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Field("_method") String method,
  );
}
