// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/blacklists/providers.dart';
import '../../../../../core/configs/config.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../pools/pool/pool.dart';
import '../../pools/pool/providers.dart';
import '../../post/post.dart';
import '../../post/providers.dart';

final danbooruPostDetailsArtistProvider = FutureProvider.family.autoDispose<
    List<DanbooruPost>,
    (BooruConfigFilter, BooruConfigSearch, String?)>((ref, params) async {
  final (filter, search, artistName) = params;

  final posts = await ref
      .watch(danbooruPostRepoProvider(search))
      .getPostsFromTagWithBlacklist(
        tag: artistName,
        blacklist: ref.watch(blacklistTagsProvider(filter).future),
      );

  posts.removeWhere((e) => e.isBanned);

  return posts;
});

final danbooruPostDetailsChildrenProvider = FutureProvider.family.autoDispose<
    List<DanbooruPost>,
    (BooruConfigFilter, BooruConfigSearch, DanbooruPost)>((ref, params) async {
  final (filter, search, post) = params;

  if (!post.hasParentOrChildren) return [];

  return ref
      .watch(danbooruPostRepoProvider(search))
      .getPostsFromTagWithBlacklist(
        tag: post.relationshipQuery,
        blacklist: ref.watch(blacklistTagsProvider(filter).future),
        softLimit: null,
      );
});

final danbooruPostDetailsPoolsProvider = FutureProvider.family
    .autoDispose<List<DanbooruPool>, int>((ref, postId) async {
  final config = ref.watchConfigAuth;
  final repo = ref.watch(danbooruPoolRepoProvider(config));

  return repo.getPoolsByPostId(postId);
});
