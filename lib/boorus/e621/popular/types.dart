// Package imports:

// Project imports:
import '../../../core/posts/explores/types.dart';
import '../../../core/posts/post/types.dart';
import '../posts/types.dart';

abstract interface class E621PopularRepository {
  PostsOrError<E621Post> getPopularPosts(DateTime date, TimeScale timeScale);
}
