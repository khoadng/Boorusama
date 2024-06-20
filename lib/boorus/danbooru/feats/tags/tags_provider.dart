// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/feats/metatags/user_metatag_repository.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'ai_tag.dart';

final popularSearchProvider =
    Provider.family<PopularSearchRepository, BooruConfig>(
  (ref, config) {
    return PopularSearchRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
    );
  },
);

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
                  category: intToTagCategory(d.category ?? 0),
                  postCount: d.postCount ?? 0,
                ))
            .toList();
      },
    );
  },
);

final danbooruUserMetatagRepoProvider = Provider<UserMetatagRepository>((ref) {
  throw UnimplementedError();
});

final danbooruUserMetatagsProvider =
    NotifierProvider<UserMetatagsNotifier, List<String>>(
  UserMetatagsNotifier.new,
  dependencies: [
    danbooruUserMetatagRepoProvider,
  ],
);

final trendingTagsProvider = AsyncNotifierProvider.autoDispose
    .family<TrendingTagNotifier, List<Search>, BooruConfig>(
  TrendingTagNotifier.new,
);

final danbooruTagCategoryProvider =
    FutureProvider.family<TagCategory?, String>((ref, tag) async {
  final config = ref.watchConfig;
  final store = ref.watch(booruTagTypeStoreProvider);
  final type = await store.get(config.booruType, tag);

  return stringToTagCategory(type);
});

final danbooruAITagsProvider = FutureProvider.family<List<AITag>, int>(
  (ref, postId) async {
    final config = ref.watchConfig;
    final booru =
        ref.watch(booruFactoryProvider).create(type: config.booruType);
    final aiTagSupport = booru?.hasAiTagSupported(config.url);

    if (aiTagSupport == null || !aiTagSupport) return [];

    final client = ref.watch(danbooruClientProvider(config));

    final tags =
        await client.getAITags(query: 'id:$postId').then((value) => value
            .map((e) => AITag(
                  score: e.score ?? 0,
                  tag: Tag(
                    name: e.tag?.name ?? '',
                    category: intToTagCategory(e.tag?.category ?? 0),
                    postCount: e.tag?.postCount ?? 0,
                  ),
                ))
            .where((e) => e.tag.postCount > 0)
            .where((e) => !e.tag.name.startsWith('rating:'))
            .toList());

    await ref.read(booruTagTypeStoreProvider).saveTagIfNotExist(
          config.booruType,
          tags.map((e) => e.tag).toList(),
        );

    return tags;
  },
);
