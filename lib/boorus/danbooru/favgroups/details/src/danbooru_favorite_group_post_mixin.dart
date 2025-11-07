// Dart imports:
import 'dart:collection';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../../../../../core/posts/post/types.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/post/types.dart';

mixin DanbooruFavoriteGroupPostMixin {
  PostRepository<DanbooruPost> get postRepository;

  Future<PostResult<DanbooruPost>> getPostsFromIdQueue(
    Queue<int> queue,
    int page, {
    int limit = 20,
  }) async {
    // Calculate skip based on page number (0-based pagination)
    final skip = page * limit;

    // Check if we have enough items
    if (queue.length < skip) {
      return <DanbooruPost>[]
          .toResult(); // Return empty result if page is beyond available items
    }

    // Skip items for pagination and take required limit
    final ids = queue.skip(skip).take(limit).toList();

    // Get posts from repository
    final r = await postRepository
        .getPostsFromIds(ids)
        .run()
        .then(
          (value) => value.fold(
            (l) => <DanbooruPost>[].toResult(),
            (r) => r,
          ),
        );

    // Create order map for sorting
    final orderMap = <int, int>{};
    for (var index = 0; index < ids.length; index++) {
      orderMap[ids[index]] = index;
    }

    // Sort posts according to original order
    final orderedPosts = r.posts
        .where((e) => orderMap.containsKey(e.id))
        .map((e) => _Payload(orderMap[e.id]!, e))
        .sorted();

    return orderedPosts.map((e) => e.post).toList().toResult();
  }
}

class _Payload implements Comparable<_Payload> {
  _Payload(this.order, this.post);

  final DanbooruPost post;
  final int order;

  @override
  int compareTo(_Payload other) {
    if (other.order < order) return 1;
    if (other.order > order) return -1;

    return 0;
  }
}
