// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/functional.dart';

class PostRepositoryCacher<T extends Post> implements PostRepository<T> {
  PostRepositoryCacher({
    required this.repository,
    required this.cache,
    this.keyBuilder,
  });

  final PostRepository<T> repository;
  final Cacher<String, List<T>> cache;
  final String Function(String tags, int page, {int? limit})? keyBuilder;

  @override
  PostsOrError<T> getPosts(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final tagString = tags;
        final defaultKey = "$tagString-$page-$limit";
        final name = keyBuilder != null
            ? keyBuilder!(tags, page, limit: limit)
            : defaultKey;

        // Check if the data exists in the cache
        if (cache.exist(name)) {
          return cache.get(name)!;
        }

        // If data is not in the cache, retrieve it from the repository and update the cache
        final data = await $(repository.getPosts(tags, page, limit: limit));

        await cache.put(name, data);

        return data;
      });
}
