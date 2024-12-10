// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../providers.dart';
import '../../pools/pool/pool.dart';
import '../../pools/pool/providers.dart';
import '../../post/post.dart';
import '../../post/providers.dart';

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
