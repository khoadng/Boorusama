import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

import 'fetcher.dart';

class PopularPostFetcher implements PostFetcher {
  const PopularPostFetcher({
    required this.date,
    required this.scale,
  });

  final DateTime date;
  final TimeScale scale;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getPopularPosts(date, page, scale);

    return posts;
  }
}
