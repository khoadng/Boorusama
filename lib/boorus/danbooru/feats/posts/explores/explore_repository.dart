// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/feats/types.dart';

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
