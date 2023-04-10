// Project imports:
import 'danbooru_post.dart';
import 'time_scale.dart';

abstract class ExploreRepository {
  Future<List<DanbooruPost>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  });

  Future<List<DanbooruPost>> getMostViewedPosts(DateTime date);

  Future<List<DanbooruPost>> getHotPosts(
    int page, {
    int? limit,
  });
}
