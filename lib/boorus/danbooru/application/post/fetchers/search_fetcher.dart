// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class SearchedPostFetcher implements PostFetcher {
  const SearchedPostFetcher({
    required this.query,
  });

  factory SearchedPostFetcher.fromTags(
    String tags, {
    PostsOrder? order,
  }) =>
      SearchedPostFetcher(query: '$tags ${_postsOrderToString(order)}');

  final String query;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getPosts(query, page);

    return posts;
  }
}

String _postsOrderToString(PostsOrder? order) {
  switch (order) {
    case PostsOrder.popular:
      return 'order:favcount';
    default:
      return '';
  }
}
