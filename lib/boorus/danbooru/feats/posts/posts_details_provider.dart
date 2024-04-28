// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

final danbooruPostDetailsArtistProvider = FutureProvider.family
    .autoDispose<List<DanbooruPost>, String>((ref, tag) async {
  return ref
      .watch(danbooruArtistCharacterPostRepoProvider(ref.watchConfig))
      .getPostsFromTagWithBlacklist(
        tag: tag,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfig)),
      );
});

final danbooruPostDetailsChildrenProvider = FutureProvider.family
    .autoDispose<List<DanbooruPost>, DanbooruPost>((ref, post) async {
  if (!post.hasParentOrChildren) return [];

  return ref
      .watch(danbooruPostRepoProvider(ref.watchConfig))
      .getPostsFromTagWithBlacklist(
        tag: post.hasParent ? 'parent:${post.parentId}' : 'parent:${post.id}',
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfig)),
        softLimit: null,
      );
});

final danbooruPostDetailsPoolsProvider =
    FutureProvider.family.autoDispose<List<Pool>, int>((ref, postId) async {
  final config = ref.watchConfig;
  final repo = ref.watch(danbooruPoolRepoProvider(config));

  return repo.getPoolsByPostId(postId);
});
