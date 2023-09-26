// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';

class PoolCoversNotifier extends Notifier<Map<PoolId, PoolCover?>> {
  @override
  Map<PoolId, PoolCover?> build() {
    ref.watch(currentBooruConfigProvider);

    return {};
  }

  PostRepository<DanbooruPost> get postRepo =>
      ref.watch(danbooruPostRepoProvider);

  Future<void> load(List<Pool>? pools) async {
    if (pools == null) return;

    final poolsWithPosts =
        pools.where((element) => element.postIds.isNotEmpty).toList();

    // only load pools that is not in the cache
    final poolsToFetch =
        poolsWithPosts.where((e) => !state.containsKey(e.id)).toList();

    if (poolsToFetch.isEmpty) return;

    final poolCoverMap = <int, PoolCover?>{
      for (var e in poolsToFetch) e.id: null,
    };

    final postPoolMap = <int, int>{
      for (var pool in poolsToFetch) pool.postIds.last: pool.id,
    };

    final posts = await postRepo
        .getPostsFromIds(postPoolMap.keys.toList())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ));

    final postMap = <int, DanbooruPost>{
      for (var post in posts) post.id: post,
    };

    for (var postId in postPoolMap.keys) {
      if (postMap.containsKey(postId)) {
        poolCoverMap[postPoolMap[postId]!] = (
          url: postToCoverUrl(postMap[postId]!),
          aspectRatio: postMap[postId]!.aspectRatio,
          id: postMap[postId]!.id,
        );
      } else {
        poolCoverMap[postPoolMap[postId]!] = (
          url: null,
          aspectRatio: 1,
          id: postId,
        );
      }
    }

    state = {
      ...state,
      ...poolCoverMap,
    };
  }
}

String? postToCoverUrl(DanbooruPost post) {
  if (post.id == 0) return null;
  if (post.isAnimated) return post.url360x360;

  return post.url720x720;
}
