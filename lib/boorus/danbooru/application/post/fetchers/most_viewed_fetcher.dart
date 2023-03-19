// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'fetcher.dart';

class MostViewedPostFetcher implements PostFetcher {
  const MostViewedPostFetcher({
    required this.date,
    required this.exploreRepository,
  });

  final DateTime date;
  final ExploreRepository exploreRepository;

  @override
  Future<List<DanbooruPost>> fetch(
    DanbooruPostRepository repo,
    int page, {
    int? limit,
  }) async {
    if (page > 1) return [];

    return exploreRepository.getMostViewedPosts(date);
  }
}
