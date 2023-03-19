// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'fetcher.dart';

class LatestPostFetcher implements PostFetcher {
  const LatestPostFetcher();

  @override
  Future<List<DanbooruPost>> fetch(
    DanbooruPostRepository repo,
    int page, {
    int? limit,
  }) async =>
      repo.getPosts('', page, limit: limit);
}
