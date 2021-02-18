// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

abstract class IApi {
  Future<HttpResponse> addToFavorites(
    String login,
    String apiKey,
    int postId,
  );

  Future<HttpResponse> removeFromFavorites(
    int postId,
    String login,
    String apiKey,
    String method,
  );

  Future<HttpResponse> filterFavoritesFromUserId(
    String login,
    String apiKey,
    String postIdsStringComma,
    int userId,
    int limit,
  );

  Future<HttpResponse> getArtist(
    String name, {
    CancelToken cancelToken,
  });

  Future<HttpResponse> getComments(
    int postId,
    int limit, {
    CancelToken cancelToken,
  });

  Future<HttpResponse> postComment(
    String login,
    String apiKey,
    int postId,
    String content,
    bool doNotBumpPost,
  );

  Future<HttpResponse> updateComment(
    String login,
    String apiKey,
    int commentId,
    String content,
  );

  Future<HttpResponse> getNotes(
    int postId, {
    CancelToken cancelToken,
  });

  Future<HttpResponse> getPost(
    String login,
    String apiKey,
    int id,
  );

  Future<HttpResponse> getArtistCommentary(
    String login,
    String apiKey,
    int postId, {
    CancelToken cancelToken,
  });

  Future<HttpResponse> getPosts(
    String login,
    String apiKey,
    int page,
    String tags,
    int limit, {
    CancelToken cancelToken,
  });

  Future<HttpResponse> getPopularPosts(
    String login,
    String apiKey,
    String date,
    String scale,
    int page,
    int limit,
  );

  Future<HttpResponse> getCuratedPosts(
    String login,
    String apiKey,
    String date,
    String scale,
    int page,
    int limit,
  );

  Future<HttpResponse> getMostViewedPosts(
    String login,
    String apiKey,
    String date,
  );

  Future<HttpResponse> getPopularSearchByDate(
    String login,
    String apiKey,
    String date,
  );

  Future<HttpResponse> getTagsByNamePattern(
    String login,
    String apiKey,
    int page,
    String hideEmpty,
    String stringPattern,
    String order,
    int limit,
  );

  Future<HttpResponse> getTagsByNameComma(
    String login,
    String apiKey,
    int page,
    String hideEmpty,
    String stringComma,
    String order,
    int limit, {
    CancelToken cancelToken,
  });

  Future<HttpResponse> getUsersByIdStringComma(
    String idComma,
    int limit, {
    CancelToken cancelToken,
  });

  Future<HttpResponse> getUserById(
    String login,
    String apiKey,
    int id,
  );

  Future<HttpResponse> getWiki(
    String subject,
  );
}
