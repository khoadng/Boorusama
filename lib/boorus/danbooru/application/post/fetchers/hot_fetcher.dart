// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class HotPostFetcher implements PostFetcher {
  const HotPostFetcher({
    required this.exploreRepository,
  });

  final ExploreRepository exploreRepository;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page, {
    int? limit,
  }) =>
      exploreRepository.getHotPosts(
        page,
        limit: limit,
      );
}
