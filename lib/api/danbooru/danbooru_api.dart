// ignore_for_file: avoid_positional_boolean_parameters

// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'danbooru_artists_api.dart';
import 'danbooru_comments_api.dart';
import 'danbooru_explores_api.dart';
import 'danbooru_favorite_groups_api.dart';
import 'danbooru_favorites_api.dart';
import 'danbooru_forums_api.dart';
import 'danbooru_pools_api.dart';
import 'danbooru_posts_api.dart';
import 'danbooru_saved_searches_api.dart';
import 'danbooru_tags_api.dart';
import 'danbooru_users_api.dart';

part 'danbooru_api.g.dart';

@RestApi()
abstract class DanbooruApi
    with
        DanbooruPostsApi,
        DanbooruTagsApi,
        DanbooruFavoritesApi,
        DanbooruCommentsApi,
        DanbooruUsersApi,
        DanbooruArtistsApi,
        DanbooruExploresApi,
        DanbooruSavedSearchesApi,
        DanbooruFavoriteGroupsApi,
        DanbooruForumsApi,
        DanbooruPoolsApi {
  factory DanbooruApi(
    Dio dio, {
    String baseUrl,
  }) = _DanbooruApi;

  @GET('/notes.json')
  Future<HttpResponse> getNotes(
    @Query('search[post_id]') int postId,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/profile.json')
  Future<HttpResponse> getProfile(
    @Query('login') String login,
    @Query('api_key') String apiKey, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/counts/posts.json')
  Future<HttpResponse> countPosts(
    @Query('tags') String tags,
  );

  @GET('/wiki_pages/{subject}.json')
  Future<HttpResponse> getWiki(
    @Path() String subject, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/autocomplete.json')
  Future<HttpResponse> autocomplete(
    @Query('search[query]') String query,
    @Query('search[type]') String type,
    @Query('limit') int limit, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
