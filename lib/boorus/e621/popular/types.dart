// Package imports:

// Project imports:
import '../../../core/posts/explores/explore.dart';
import '../../../core/posts/post/post.dart';
import '../posts/types.dart';

abstract interface class E621PopularRepository {
  PostsOrError<E621Post> getPopularPosts(DateTime date, TimeScale timeScale);
}
