// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetchers.dart';

class ExplorePreviewFetcher implements PostFetcher {
  const ExplorePreviewFetcher({
    required this.category,
    required this.date,
    required this.scale,
    this.limit = 20,
  });

  factory ExplorePreviewFetcher.now({
    required ExploreCategory category,
  }) =>
      ExplorePreviewFetcher(
        category: category,
        date: DateTime.now(),
        scale: TimeScale.day,
      );

  final ExploreCategory category;
  final DateTime date;
  final TimeScale scale;
  final int limit;

  @override
  Future<List<Post>> fetch(PostRepository repo, int page) async {
    var posts = await _categoryToFetcher(date).fetch(repo, page);

    if (posts.isEmpty) {
      posts = await _categoryToFetcher(date.subtract(const Duration(days: 1)))
          .fetch(repo, page);
    }

    return posts.take(limit).toList();
  }

  PostFetcher _categoryToFetcher(DateTime d) {
    if (category == ExploreCategory.popular) {
      return PopularPostFetcher(date: d, scale: scale);
    } else if (category == ExploreCategory.curated) {
      return CuratedPostFetcher(date: d, scale: scale);
    } else if (category == ExploreCategory.hot) {
      return const HotPostFetcher();
    } else {
      return MostViewedPostFetcher(date: d);
    }
  }
}
