// ignore_for_file: avoid_positional_boolean_parameters

// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'danbooru_api_artists.dart';
import 'danbooru_api_comments.dart';
import 'danbooru_api_explores.dart';
import 'danbooru_api_favorite_groups.dart';
import 'danbooru_api_favorites.dart';
import 'danbooru_api_forums.dart';
import 'danbooru_api_pools.dart';
import 'danbooru_api_posts.dart';
import 'danbooru_api_reports.dart';
import 'danbooru_api_saved_searches.dart';
import 'danbooru_api_tags.dart';
import 'danbooru_api_users.dart';

part 'danbooru_api.g.dart';

@RestApi()
abstract class DanbooruApi
    with
        DanbooruApiPosts,
        DanbooruApiTags,
        DanbooruApiFavorites,
        DanbooruApiComments,
        DanbooruApiUsers,
        DanbooruApiArtists,
        DanbooruApiExplores,
        DanbooruApiSavedSearches,
        DanbooruApiFavoriteGroups,
        DanbooruApiForums,
        DanbooruApiReports,
        DanbooruApiPools {
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
