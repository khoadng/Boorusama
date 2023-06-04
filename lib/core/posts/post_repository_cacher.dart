// Project imports:
import 'package:boorusama/core/caching/caching.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';

class PostRepositoryCacher implements PostRepository {
  PostRepositoryCacher({
    required this.repository,
    required this.cache,
  });

  final PostRepository repository;
  final Cacher<String, List<Post>> cache;

  @override
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) {
    final name = "$tags-$page-$limit";

    // Check if the data exists in the cache
    if (cache.exist(name)) {
      return TaskEither.of(cache.get(name)!);
    }

    // If data is not in the cache, retrieve it from the repository and update the cache
    return repository
        .getPostsFromTags(tags, page)
        .flatMap((r) => TaskEither(() async {
              await cache.put(name, r);
              return Either.of(r);
            }));
  }
}
