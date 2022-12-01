// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class CuratedPostFetcher implements PostFetcher {
  const CuratedPostFetcher({
    required this.date,
    required this.scale,
    required this.exploreRepository,
  });

  final DateTime date;
  final TimeScale scale;
  final ExploreRepository exploreRepository;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page, {
    int? limit,
  }) async =>
      exploreRepository.getCuratedPosts(
        date,
        page,
        scale,
        limit: limit,
      );
}
