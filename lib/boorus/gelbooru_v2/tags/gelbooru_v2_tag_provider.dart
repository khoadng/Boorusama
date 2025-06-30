// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../gelbooru_v2.dart';
import '../posts/posts_v2.dart';

final gelbooruV2TagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, int>(
  (ref, id) async {
    final config = ref.watchConfigAuth;
    final client = ref.watch(gelbooruV2ClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data
        .map(
          (e) => Tag(
            name: e.name ?? '',
            category: TagCategory.fromLegacyId(e.type),
            postCount: e.count ?? 0,
          ),
        )
        .toList();
  },
);

final gelbooruV2TagGroupRepoProvider =
    Provider.family<TagGroupRepository<GelbooruV2Post>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post) async {
        final tags =
            await ref.read(gelbooruV2TagsFromIdProvider(post.id).future);

        return createTagGroupItems(tags);
      },
    );
  },
);
