// Project imports:
import 'post.dart';
import 'time_scale.dart';

abstract class ExploreRepository {
  Future<List<Post>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  });

  Future<List<Post>> getCuratedPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  });

  Future<List<Post>> getMostViewedPosts(DateTime date);

  Future<List<Post>> getHotPosts(
    int page, {
    int? limit,
  });
}
