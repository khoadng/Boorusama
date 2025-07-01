// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/riverpod/riverpod.dart';
import '../data/providers.dart';

final moebooruPostDetailsChildrenProvider =
    FutureProvider.family.autoDispose<List<Post>?, (BooruConfigSearch, Post)>(
  (ref, params) async {
    ref.cacheFor(const Duration(seconds: 60));

    final (config, post) = params;

    if (!post.hasParentOrChildren) return null;
    final repo = ref.watch(moebooruPostRepoProvider(config));

    final query =
        post.parentId != null ? 'parent:${post.parentId}' : 'parent:${post.id}';

    final r = await repo.getPostsFromTagsOrEmpty(query);

    return r.posts;
  },
);
