// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

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
  Future<List<DanbooruPost>> fetch(
    DanbooruPostRepository repo,
    int page, {
    int? limit,
  }) async =>
      repo.getPosts(
        query,
        page,
        limit: limit,
      );
}

String _postsOrderToString(PostsOrder? order) {
  if (order == null) return '';

  switch (order) {
    case PostsOrder.popular:
      return 'order:favcount';
    case PostsOrder.newest:
      return '';
  }
}
