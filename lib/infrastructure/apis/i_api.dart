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

  Future<HttpResponse> getComments(
    int postId,
    int limit,
  );

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
    int postId,
  );

  Future<HttpResponse> getPosts(
    String login,
    String apiKey,
    int page,
    String tags,
    int limit,
  );

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
    int limit,
  );

  Future<HttpResponse> getUsersByIdStringComma(
    String idComma,
    int limit,
  );

  Future<HttpResponse> getUserById(
    String login,
    String apiKey,
    int id,
  );

  Future<HttpResponse> getWiki(
    String subject,
  );
}
