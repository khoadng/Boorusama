// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class LatestPostFetcher implements PostFetcher {
  const LatestPostFetcher();

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page, {
    int? limit,
  }) async =>
      repo.getPosts('', page, limit: limit);
}
