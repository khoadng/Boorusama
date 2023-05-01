// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';
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

    return cache.get(name).toOption().fold(
          () => repository.getPostsFromTags(tags, page).map((r) {
            cache.put(name, r);
            return r;
          }),
          (t) => TaskEither.of(t),
        );
  }
}
