// Dart imports:
import 'dart:collection';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/utils/collection_utils.dart';

mixin DanbooruFavoriteGroupPostMixin {
  DanbooruPostRepository get postRepository;

  Future<List<DanbooruPost>> getPostsFromIdQueue(Queue<int> queue) async {
    final ids = queue.dequeue(20);

    final posts = await postRepository.getPostsFromIds(
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

  final DanbooruPost post;
  final int order;

  @override
  int compareTo(_Payload other) {
    if (other.order < order) return 1;
    if (other.order > order) return -1;

    return 0;
  }
}
