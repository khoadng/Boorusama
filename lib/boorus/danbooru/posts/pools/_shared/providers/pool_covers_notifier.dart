// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';
import '../../pool/pool.dart';

final danbooruPoolCoversProvider =
    NotifierProvider.family<
      PoolCoversNotifier,
      Map<int, PoolCover?>,
      BooruConfigSearch
    >(
      PoolCoversNotifier.new,
    );

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

  PostRepository<DanbooruPost> get _postRepo =>
      ref.watch(danbooruPostRepoProvider(arg));

  Future<void> load(List<DanbooruPool>? pools) async {
    if (pools == null) return;

    final poolsWithPosts = pools
        .where((element) => element.postIds.isNotEmpty)
        .toList();

    // only load pools that is not in the cache
    final poolsToFetch = poolsWithPosts
        .where((e) => !state.containsKey(e.id))
        .toList();

    if (poolsToFetch.isEmpty) return;

    final poolCoverMap = <int, PoolCover?>{
      for (final e in poolsToFetch) e.id: null,
    };

    final postPoolMap = <int, int>{
      for (final pool in poolsToFetch) pool.postIds.last: pool.id,
    };

    final r = await _postRepo
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
