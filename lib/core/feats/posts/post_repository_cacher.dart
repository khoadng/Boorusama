// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/functional.dart';

class PostRepositoryCacher implements PostRepository {
  PostRepositoryCacher({
    required this.repository,
    required this.cache,
  });

  final PostRepository repository;
  final Cacher<String, List<Post>> cache;

  @override
  PostsOrError getPosts(
    List<String> tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final tagString = tags.join(' ');
        final name = "$tagString-$page-$limit";

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
