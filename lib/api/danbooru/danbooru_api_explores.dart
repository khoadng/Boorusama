// Package imports:
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiExplores {
  @GET('/explore/posts/popular.json')
  Future<HttpResponse> getPopularPosts(
    @Query('date') String date,
    @Query('scale') String scale,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/explore/posts/viewed.json')
  Future<HttpResponse> getMostViewedPosts(
    @Query('date') String date,
  );

  @GET('/explore/posts/searches.json')
  Future<HttpResponse> getPopularSearchByDate(
    @Query('date') String date,
  );
}
