// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../core/posts/post/types.dart';
import '../../../../posts/post/providers.dart';
import '../../../../posts/post/types.dart';
import '../../types.dart';
import '../types/pool_cover.dart';

final danbooruPoolCoversProvider =
    NotifierProvider.family<
      PoolCoversNotifier,
      Map<int, PoolCover?>,
      BooruConfigSearch
    >(PoolCoversNotifier.new);

final danbooruPoolCoverProvider = Provider.autoDispose
    .family<PoolCover?, PoolId>((ref, id) {
      final config = ref.watchConfigSearch;
      final covers = ref.watch(danbooruPoolCoversProvider(config));

      return covers[id];
    });

class PoolCoversNotifier
    extends FamilyNotifier<Map<PoolId, PoolCover?>, BooruConfigSearch> {
  @override
  Map<PoolId, PoolCover?> build(BooruConfigSearch arg) {
    return {};
  }

  PostRepository<DanbooruPost> get postRepo =>
      ref.watch(danbooruPostRepoProvider(arg));

  Future<void> load(List<DanbooruPool>? pools) async {
    if (pools == null) return;

    final poolsWithPosts = pools
        .where((element) => element.postIds?.isNotEmpty ?? false)
        .toList();

    // only load pools that is not in the cache
    final poolsToFetch = poolsWithPosts
        .where((e) => !state.containsKey(e.id))
        .toList();

    if (poolsToFetch.isEmpty) return;

    final poolCoverMap = <int, PoolCover?>{
      for (final e in poolsToFetch) e.id: null,
    };

    final postPoolMap = Map<int, int>.fromEntries(
      poolsToFetch.map(
        (pool) {
          final postId = pool.postIds?.lastOrNull;
          return postId == null ? null : MapEntry(postId, pool.id);
        },
      ).nonNulls,
    );

    final r = await postRepo
        .getPostsFromIds(postPoolMap.keys.toList())
        .run()
        .then(
          (value) => value.fold(
            (l) => <DanbooruPost>[].toResult(),
            (r) => r,
          ),
        );

    final postMap = <int, DanbooruPost>{
      for (final post in r.posts) post.id: post,
    };

    for (final postId in postPoolMap.keys) {
      if (postMap.containsKey(postId)) {
        poolCoverMap[postPoolMap[postId]!] = PoolCover.fromPost(
          postMap[postId]!,
        );
      } else {
        poolCoverMap[postPoolMap[postId]!] = PoolCover.empty(postId);
      }
    }

    state = {
      ...state,
      ...poolCoverMap,
    };
  }
}
