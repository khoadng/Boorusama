// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class PostRepositoryCacher implements PostRepository {
  PostRepositoryCacher({
    required this.repository,
    required this.cache,
  });

  final PostRepository repository;
  final Cacher<String, List<Post>> cache;

  @override
  Future<List<Post>> getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) async {
    final name = "$tags-$page-$limit";

    final item = cache.get(name);

    if (item != null) return item;

    final fresh = await repository.getPostsFromTags(
      tags,
      page,
      limit: limit,
    );

    await cache.put(name, fresh);

    return fresh;
  }
}
