// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class MostViewedPostFetcher implements PostFetcher {
  const MostViewedPostFetcher({
    required this.date,
  });

  final DateTime date;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    if (page > 1) return [];

    return repo.getMostViewedPosts(date);
  }
}
