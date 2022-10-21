// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class HotPostFetcher implements PostFetcher {
  const HotPostFetcher();

  @override
  Future<List<Post>> fetch(PostRepository repo, int page) =>
      repo.getPosts('order:rank', page);
}
