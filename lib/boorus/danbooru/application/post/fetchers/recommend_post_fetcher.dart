// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetcher.dart';

class RecommendPostFetcher implements PostFetcher {
  const RecommendPostFetcher({
    required this.tag,
    required this.postId,
    required this.amount,
  });

  final int postId;
  final String tag;
  final int amount;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getPosts(
      tag,
      1,
      limit: 10,
      skipFavoriteCheck: true,
    );

    return posts.take(amount).toList();
  }
}
