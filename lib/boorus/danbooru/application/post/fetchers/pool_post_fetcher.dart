// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class PoolPostFetcher implements PostFetcher {
  const PoolPostFetcher({
    required this.postIds,
  });

  final List<int> postIds;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page, {
    int? limit,
  }) async =>
      repo.getPostsFromIds(postIds);
}
