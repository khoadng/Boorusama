// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/functional.dart';

final popularSearchProvider = Provider<PopularSearchRepository>(
  (ref) {
    return PopularSearchRepositoryApi(
      client: ref.watch(danbooruClientProvider),
    );
  },
);

final danbooruTagRepoProvider = Provider<TagRepository>(
  (ref) {
    final client = ref.watch(danbooruClientProvider);

    return TagRepositoryBuilder(
      maxCapacity: 2000,
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

final trendingTagsProvider =
    AsyncNotifierProvider<TrendingTagNotifier, List<Search>>(
  TrendingTagNotifier.new,
);

final shouldFetchTrendingProvider = Provider<bool>((ref) {
  final config = ref.watch(currentBooruConfigProvider);
  final booruType = intToBooruType(config.booruId);

  return booruType == BooruType.danbooru;
});

final danbooruTagCategoryRepoProvider = Provider<DanbooruTagCategoryRepository>(
  (ref) {
    return DanbooruTagCategoryRepository();
  },
);

final danbooruTagCategoriesProviderProvider =
    NotifierProvider<DanbooruTagCategoryNotifier, IMap<String, TagCategory>>(
  DanbooruTagCategoryNotifier.new,
  dependencies: [
    danbooruTagCategoryRepoProvider,
    danbooruTagRepoProvider,
  ],
);

final danbooruTagCategoryProvider = Provider.family<TagCategory?, String>(
    (ref, tag) => ref.watch(danbooruTagCategoriesProviderProvider)[tag]);
