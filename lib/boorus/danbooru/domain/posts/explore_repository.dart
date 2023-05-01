// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

abstract class ExploreRepository {
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  });

  DanbooruPostsOrError getMostViewedPosts(DateTime date);

  DanbooruPostsOrError getHotPosts(
    int page, {
    int? limit,
  });
}
