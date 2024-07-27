// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';

final danbooruTagRepoProvider = Provider.family<TagRepository, BooruConfig>(
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
            .map((d) => Tag(
                  name: d.name ?? '',
                  category: TagCategory.fromLegacyId(d.category ?? 0),
                  postCount: d.postCount ?? 0,
                ))
            .toList();
      },
    );
  },
);

final danbooruTagCategoryProvider =
    FutureProvider.family<TagCategory?, String>((ref, tag) async {
  final config = ref.watchConfig;
  final store = ref.watch(booruTagTypeStoreProvider);
  final type = await store.get(config.booruType, tag);

  return TagCategory.fromLegacyIdString(type);
});
