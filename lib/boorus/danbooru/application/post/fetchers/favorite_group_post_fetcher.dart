// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_repository.dart';
import 'fetcher.dart';

class FavoriteGroupPostFetcher implements PostFetcher {
  FavoriteGroupPostFetcher({
    required this.ids,
  });

  final List<int> ids;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page, {
    int? limit,
  }) async {
    final posts = await repo.getPostsFromIds(
      ids,
    );

    final orderMap = <int, int>{};
    for (var index = 0; index < ids.length; index++) {
      orderMap[ids[index]] = index;
    }

    final orderedPosts = posts
        .where((e) => orderMap.containsKey(e.id))
        .map((e) => _Payload(orderMap[e.id]!, e))
        .sorted();

    return orderedPosts.map((e) => e.post).toList();
  }
}

class _Payload implements Comparable<_Payload> {
  _Payload(this.order, this.post);

  final Post post;
  final int order;

  @override
  int compareTo(_Payload other) {
    if (other.order < order) return 1;
    if (other.order > order) return -1;

    return 0;
  }
}
