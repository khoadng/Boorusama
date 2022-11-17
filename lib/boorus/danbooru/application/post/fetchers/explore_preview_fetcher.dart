// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetchers.dart';

class ExplorePreviewFetcher implements PostFetcher {
  const ExplorePreviewFetcher({
    required this.category,
    required this.date,
    required this.scale,
    required this.exploreRepository,
  });

  factory ExplorePreviewFetcher.now({
    required ExploreCategory category,
    required ExploreRepository exploreRepository,
  }) =>
      ExplorePreviewFetcher(
        category: category,
        date: DateTime.now(),
        scale: TimeScale.day,
        exploreRepository: exploreRepository,
      );

  final ExploreCategory category;
  final ExploreRepository exploreRepository;
  final DateTime date;
  final TimeScale scale;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page, {
    int? limit,
  }) async {
    var posts = await _categoryToFetcher(date).fetch(
      repo,
      page,
      limit: limit,
    );

    if (posts.isEmpty) {
      posts = await _categoryToFetcher(date.subtract(const Duration(days: 1)))
          .fetch(
        repo,
        page,
        limit: limit,
      );
    }

    return posts.toList();
  }

  PostFetcher _categoryToFetcher(DateTime d) {
    switch (category) {
      case ExploreCategory.popular:
        return PopularPostFetcher(
          date: d,
          scale: scale,
          exploreRepository: exploreRepository,
        );
      case ExploreCategory.curated:
        return CuratedPostFetcher(
          date: d,
          scale: scale,
          exploreRepository: exploreRepository,
        );
      case ExploreCategory.mostViewed:
        return MostViewedPostFetcher(
          date: d,
          exploreRepository: exploreRepository,
        );
      case ExploreCategory.hot:
        return HotPostFetcher(
          exploreRepository: exploreRepository,
        );
    }
  }
}
