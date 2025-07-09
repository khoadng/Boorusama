// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/ref.dart';
import '../../../../core/tags/categories/providers.dart';
import '../../../../core/tags/categories/tag_category.dart';
import '../../../../core/tags/tag/tag.dart';
import '../../client_provider.dart';
import '../../danbooru.dart';
import 'ai.dart';

final danbooruAITagsProvider = FutureProvider.family<List<AITag>, int>(
  (ref, postId) async {
    final config = ref.watchConfigAuth;
    final booru = ref.watch(danbooruProvider);
    final aiTagSupport = booru.hasAiTagSupported(config.url);

    if (!aiTagSupport) return [];

    final client = ref.watch(danbooruClientProvider(config));

    final tags = await client
        .getAITags(query: 'id:$postId')
        .then(
          (value) => value
              .map(
                (e) => AITag(
                  score: e.score ?? 0,
                  tag: Tag(
                    name: e.tag?.name ?? '',
                    category: TagCategory.fromLegacyId(e.tag?.category),
                    postCount: e.tag?.postCount ?? 0,
                  ),
                ),
              )
              .where((e) => e.tag.postCount > 0)
              .where((e) => !e.tag.name.startsWith('rating:'))
              .toList(),
        );

    final tagTypeStore = await ref.watch(booruTagTypeStoreProvider.future);

    await tagTypeStore.saveTagIfNotExist(
      config.url,
      tags.map((e) => e.tag).toList(),
    );

    return tags;
  },
);
