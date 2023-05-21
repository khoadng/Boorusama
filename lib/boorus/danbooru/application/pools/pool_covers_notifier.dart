// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/boorus.dart';

class PoolCoversNotifier extends Notifier<Map<PoolId, PoolCover?>> {
  @override
  Map<PoolId, PoolCover?> build() {
    // Doesn't work
    // ref.listen(
    //   danbooruPoolsProvider,
    //   (previous, next) => load(next.records),
    // );

    ref.watch(currentBooruConfigProvider);

    return {};
  }

  DanbooruPostRepository get postRepo => ref.watch(danbooruPostRepoProvider);

  Future<void> load(List<Pool>? pools) async {
    if (pools == null) return;

    final poolFiltered =
        pools.where((element) => element.postIds.isNotEmpty).toList();

    final poolCoverMap = <int, PoolCover?>{
      for (var e in poolFiltered) e.id: null,
    };

    final postPoolMap = <int, int>{
      for (var e in poolFiltered) e.postIds.last: e.id,
    };

    final posts = await postRepo
        .getPostsFromIds(postPoolMap.keys.toList())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ));

    final postMap = <int, DanbooruPost>{
      for (var e in posts) e.id: e,
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
