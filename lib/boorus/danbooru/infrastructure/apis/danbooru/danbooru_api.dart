// Package imports:
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'dio_connectivity_request_retrier.dart';
import 'retry_interceptor.dart';

part 'danbooru_api.g.dart';

final apiProvider = Provider<IApi>((ref) {
  final dio = Dio();
  final endPoint = ref.watch(apiEndpointProvider);
  dio.interceptors
    ..add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: Dio(),
          connectivity: Connectivity(),
        ),
      ),
    )
    ..add(DioCacheManager(CacheConfig(baseUrl: endPoint)).interceptor);
  return DanbooruApi(
    dio,
    baseUrl: endPoint,
  );
});

final apiEndpointProvider = Provider<String>((ref) {
  return "https://danbooru.donmai.us/";
});

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

  @GET("/favorites.json")
  @override
  Future<HttpResponse> filterFavoritesFromUserId(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("search[post_id]") String postIdsString,
    @Query("search[user_id]") int userId,
    @Query("limit") int limit,
  );

  @GET("/comments.json")
  @override
  Future<HttpResponse> getComments(
    @Query("search[post_id]") int postId,
    @Query("limit") int limit, {
    @CancelRequest() CancelToken cancelToken,
  });

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

  @Extra({
    DIO_CACHE_KEY_TRY_CACHE: true,
    DIO_CACHE_KEY_MAX_AGE: Duration(seconds: 10),
  })
  @GET("/notes.json")
  @override
  Future<HttpResponse> getNotes(
    @Query("search[post_id]") int postId, {
    @CancelRequest() CancelToken cancelToken,
  });

  @GET("/posts.json")
  @override
  Future<HttpResponse> getPosts(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("page") int page,
    @Query("tags") String tags,
    @Query("limit") int limit, {
    @CancelRequest() CancelToken cancelToken,
  });

  @Extra({
    DIO_CACHE_KEY_TRY_CACHE: true,
    DIO_CACHE_KEY_MAX_AGE: Duration(seconds: 3),
  })
  @GET("/posts/{postId}")
  @override
  Future<HttpResponse> getPost(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Path() int postId,
  );

  @GET("/artist_commentaries.json")
  @override
  Future<HttpResponse> getArtistCommentary(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("search[post_id]") int postId, {
    @CancelRequest() CancelToken cancelToken,
  });

  @GET("/explore/posts/popular.json")
  @override
  Future<HttpResponse> getPopularPosts(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("date") String date,
    @Query("scale") String scale,
    @Query("page") int page,
    @Query("limit") int limit,
  );

  @GET("/explore/posts/curated.json")
  @override
  Future<HttpResponse> getCuratedPosts(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("date") String date,
    @Query("scale") String scale,
    @Query("page") int page,
    @Query("limit") int limit,
  );

  @GET("/explore/posts/viewed.json")
  @override
  Future<HttpResponse> getMostViewedPosts(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("date") String date,
  );

  @GET("/explore/posts/searches.json")
  @override
  Future<HttpResponse> getPopularSearchByDate(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("date") String date,
  );

  @Extra({
    DIO_CACHE_KEY_TRY_CACHE: true,
    DIO_CACHE_KEY_MAX_AGE: Duration(days: 7),
  })
  @GET("/tags.json")
  @override
  Future<HttpResponse> getTagsByNamePattern(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("page") int page,
    @Query("search[hide_empty]") String hideEmpty,
    @Query("search[name_or_alias_matches]") String stringPattern,
    @Query("search[order]") String order,
    @Query("limit") int limit,
  );

  @Extra({
    DIO_CACHE_KEY_TRY_CACHE: true,
    DIO_CACHE_KEY_MAX_AGE: Duration(days: 7),
  })
  @GET("/tags.json")
  @override
  Future<HttpResponse> getTagsByNameComma(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Query("page") int page,
    @Query("search[hide_empty]") String hideEmpty,
    @Query("search[name_comma]") String stringComma,
    @Query("search[order]") String order,
    @Query("limit") int limit, {
    @CancelRequest() CancelToken cancelToken,
  });

  @Extra({
    DIO_CACHE_KEY_TRY_CACHE: true,
    DIO_CACHE_KEY_MAX_AGE: Duration(days: 7),
  })
  @GET("/users.json")
  @override
  Future<HttpResponse> getUsersByIdStringComma(
    @Query("search[id]") String idComma,
    @Query("limit") int limit, {
    @CancelRequest() CancelToken cancelToken,
  });

  @Extra({
    DIO_CACHE_KEY_TRY_CACHE: true,
    DIO_CACHE_KEY_MAX_AGE: Duration(days: 90),
  })
  @GET("/users/{id}.json")
  @override
  Future<HttpResponse> getUserById(
    @Query("login") String login,
    @Query("api_key") String apiKey,
    @Path() int id,
  );

  @Extra({
    DIO_CACHE_KEY_TRY_CACHE: true,
    DIO_CACHE_KEY_MAX_AGE: Duration(hours: 1),
  })
  @GET("/wiki_pages/{subject}.json")
  @override
  Future<HttpResponse> getWiki(
    @Path() String subject,
  );
}
