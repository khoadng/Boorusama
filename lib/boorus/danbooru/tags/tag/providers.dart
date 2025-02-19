// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config.dart';
import '../../../../core/configs/ref.dart';
import '../../../../core/tags/categories/providers.dart';
import '../../../../core/tags/categories/tag_category.dart';
import '../../../../core/tags/tag/providers.dart';
import '../../../../core/tags/tag/tag.dart';
import '../../danbooru_provider.dart';

final danbooruTagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(danbooruClientProvider(config));

    return TagRepositoryBuilder(
      persistentStorageKey: '${Uri.encodeComponent(config.url)}_tags_cache_v1',
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTagsByName(
          page: page,
          hideEmpty: true,
          tags: tags,
          cancelToken: cancelToken,
        );

        return data
            .map(
              (d) => Tag(
                name: d.name ?? '',
                category: TagCategory.fromLegacyId(d.category ?? 0),
                postCount: d.postCount ?? 0,
              ),
            )
            .toList();
      },
    );
  },
);

final danbooruTagCategoryProvider =
    FutureProvider.family<TagCategory?, String>((ref, tag) async {
  final config = ref.watchConfigAuth;
  final store = ref.watch(booruTagTypeStoreProvider);
  final type = await store.get(config.booruType, tag);

  return TagCategory.fromLegacyIdString(type);
});
