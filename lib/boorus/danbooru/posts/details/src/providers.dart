// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/blacklists/providers.dart';
import '../../../../../core/configs/config.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/riverpod/riverpod.dart';
import '../../pools/pool/pool.dart';
import '../../pools/pool/providers.dart';
import '../../post/post.dart';
import '../../post/providers.dart';

final danbooruPostDetailsChildrenProvider = FutureProvider.family.autoDispose<
    List<DanbooruPost>,
    (BooruConfigFilter, BooruConfigSearch, DanbooruPost)>((ref, params) async {
  ref.cacheFor(const Duration(seconds: 60));

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
    .autoDispose<List<DanbooruPool>, (BooruConfigAuth, int)>(
        (ref, params) async {
  final (config, postId) = params;
  final repo = ref.watch(danbooruPoolRepoProvider(config));

  return repo.getPoolsByPostId(postId);
});
