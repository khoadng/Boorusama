// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/posts.dart';

final danbooruPostDetailsArtistProvider = FutureProvider.family
    .autoDispose<List<DanbooruPost>, String>((ref, tag) async {
  final config = ref.watchConfigSearch;
  final posts = await ref
      .watch(danbooruPostRepoProvider(config))
      .getPostsFromTagWithBlacklist(
        tag: tag,
        blacklist: ref.watch(blacklistTagsProvider(config.auth).future),
      );

  posts.removeWhere((e) => e.isBanned);

  return posts;
});

final danbooruPostDetailsChildrenProvider = FutureProvider.family
    .autoDispose<List<DanbooruPost>, DanbooruPost>((ref, post) async {
  if (!post.hasParentOrChildren) return [];

  final config = ref.watchConfigSearch;

  return ref
      .watch(danbooruPostRepoProvider(config))
      .getPostsFromTagWithBlacklist(
        tag: post.relationshipQuery,
        blacklist: ref.watch(blacklistTagsProvider(config.auth).future),
        softLimit: null,
      );
});

final danbooruPostDetailsPoolsProvider = FutureProvider.family
    .autoDispose<List<DanbooruPool>, int>((ref, postId) async {
  final config = ref.watchConfigAuth;
  final repo = ref.watch(danbooruPoolRepoProvider(config));

  return repo.getPoolsByPostId(postId);
});
