// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';

class PoolCoversNotifier
    extends FamilyNotifier<Map<PoolId, PoolCover?>, BooruConfig> {
  @override
  Map<PoolId, PoolCover?> build(BooruConfig arg) {
    return {};
  }

  PostRepository<DanbooruPost> get postRepo =>
      ref.watch(danbooruPostRepoProvider(arg));

  Future<void> load(List<DanbooruPool>? pools) async {
    if (pools == null) return;

    final poolsWithPosts =
        pools.where((element) => element.postIds.isNotEmpty).toList();

    // only load pools that is not in the cache
    final poolsToFetch =
        poolsWithPosts.where((e) => !state.containsKey(e.id)).toList();

    if (poolsToFetch.isEmpty) return;

    final poolCoverMap = <int, PoolCover?>{
      for (final e in poolsToFetch) e.id: null,
    };

    final postPoolMap = <int, int>{
      for (final pool in poolsToFetch) pool.postIds.last: pool.id,
    };

    final r = await postRepo
        .getPostsFromIds(postPoolMap.keys.toList())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[].toResult(),
              (r) => r,
            ));

    final postMap = <int, DanbooruPost>{
      for (final post in r.posts) post.id: post,
    };

    for (final postId in postPoolMap.keys) {
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
