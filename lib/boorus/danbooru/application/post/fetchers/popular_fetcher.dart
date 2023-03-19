// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class PopularPostFetcher implements PostFetcher {
  const PopularPostFetcher({
    required this.date,
    required this.scale,
    required this.exploreRepository,
  });

  final DateTime date;
  final TimeScale scale;
  final ExploreRepository exploreRepository;

  @override
  Future<List<DanbooruPost>> fetch(
    DanbooruPostRepository repo,
    int page, {
    int? limit,
  }) async =>
      exploreRepository.getPopularPosts(
        date,
        page,
        scale,
        limit: limit,
      );
}
