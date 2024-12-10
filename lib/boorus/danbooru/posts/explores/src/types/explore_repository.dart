// Package imports:

// Project imports:
import 'package:boorusama/core/datetimes/types.dart';
import '../../../post/post.dart';

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
