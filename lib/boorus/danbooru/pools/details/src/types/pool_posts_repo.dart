// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../../../../../../core/posts/post/types.dart';
import '../../../../posts/post/types.dart';
import '../../../pool/types.dart';
import 'pool_details_order.dart';

extension PoolPostsRepo on PostRepository<DanbooruPost> {
  Future<PostResult<DanbooruPost>> fetchPoolPosts({
    required DanbooruPool pool,
    required int page,
    required int perPage,
    required PoolDetailsOrder order,
  }) async {
    final sortedIds = _sortPostIds(pool.postIds ?? [], order);
    final paginatedIds = _paginate(sortedIds, page, perPage);

    if (paginatedIds.isEmpty) {
      return <DanbooruPost>[].toResult(
        total: sortedIds.length,
      );
    }

    return _fetchPosts(this, paginatedIds, sortedIds.length);
  }

  List<int> _sortPostIds(List<int> ids, PoolDetailsOrder order) {
    final postIds = [...ids];

    return switch (order) {
      PoolDetailsOrder.latest => postIds.sorted((a, b) => b.compareTo(a)),
      PoolDetailsOrder.oldest => postIds.sorted((a, b) => a.compareTo(b)),
      PoolDetailsOrder.order => postIds,
    };
  }

  List<int> _paginate(List<int> ids, int page, int perPage) {
    final start = (page - 1) * perPage;
    var end = start + perPage;

    if (start >= ids.length) {
      return [];
    }

    if (end > ids.length) {
      end = ids.length;
    }

    return ids.sublist(start, end);
  }

  Future<PostResult<DanbooruPost>> _fetchPosts(
    PostRepository<DanbooruPost> repo,
    List<int> ids,
    int totalCount,
  ) async {
    final result = await repo
        .getPosts('id:${ids.join(',')}', 1)
        .run()
        .then(
          (value) => value.fold(
            (l) => <DanbooruPost>[].toResult(),
            (r) => r,
          ),
        );

    final ordered = <DanbooruPost>[];
    for (final id in ids) {
      final post = result.posts.firstWhereOrNull((post) => post.id == id);
      if (post != null) {
        ordered.add(post);
      }
    }

    return ordered.toResult(total: totalCount);
  }
}
