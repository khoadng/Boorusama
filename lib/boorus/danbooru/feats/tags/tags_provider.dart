// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/metatags/user_metatag_repository.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/functional.dart';

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

final trendingTagsProvider = AsyncNotifierProvider.family<TrendingTagNotifier,
    List<Search>, BooruConfig>(
  TrendingTagNotifier.new,
);

final shouldFetchTrendingProvider = Provider<bool>((ref) {
  final config = ref.watchConfig;
  final booruType = intToBooruType(config.booruId);

  return booruType == BooruType.danbooru;
});

final danbooruTagCategoryRepoProvider =
    Provider.family<DanbooruTagCategoryRepository, BooruConfig>(
  (ref, config) {
    return DanbooruTagCategoryRepository(config: config);
  },
);

final danbooruTagCategoriesProviderProvider = NotifierProvider.family<
    DanbooruTagCategoryNotifier, IMap<String, TagCategory>, BooruConfig>(
  DanbooruTagCategoryNotifier.new,
  dependencies: [
    danbooruTagCategoryRepoProvider,
    danbooruTagRepoProvider,
  ],
);

final danbooruTagCategoryProvider =
    Provider.family<TagCategory?, String>((ref, tag) {
  final config = ref.watchConfig;
  return ref.watch(danbooruTagCategoriesProviderProvider(config))[tag];
});
