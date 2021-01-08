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
}
