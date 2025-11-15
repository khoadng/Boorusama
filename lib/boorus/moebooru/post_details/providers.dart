// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/providers.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../posts/providers.dart';
import '../posts/types.dart';

final moebooruPostDetailsChildrenProvider = FutureProvider.family
    .autoDispose<List<Post>?, (BooruConfigSearch, Post)>(
      (ref, params) async {
        ref.cacheFor(const Duration(seconds: 60));

        final (config, post) = params;

        if (!post.hasParentOrChildren) return null;
        final repo = ref.watch(moebooruPostRepoProvider(config));

        final query = post.parentId != null
            ? 'parent:${post.parentId}'
            : 'parent:${post.id}';

        final r = await repo.getPostsFromTagsOrEmpty(query);

        return r.posts;
      },
    );

final moebooruMediaUrlResolverProvider =
    Provider.family<MediaUrlResolver, BooruConfigAuth>(
      (ref, config) => ref.watch(defaultMediaUrlResolverProvider(config)),
    );

final moebooruUploaderQueryProvider =
    Provider.family<UploaderQuery?, MoebooruPost>((ref, post) {
      return switch (post.uploaderName) {
        final uploader? => UserColonUploaderQuery(uploader),
        _ => null,
      };
    });
