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
}
