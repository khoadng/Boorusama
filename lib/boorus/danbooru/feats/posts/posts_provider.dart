// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final danbooruPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return PostRepositoryBuilder(
    fetch: (tags, page, {limit}) async {
      final posts = await client
          .getPosts(
            page: page,
            tags: tags,
            limit: limit,
          )
          .then((value) => value.map(postDtoToPost).toList());

      return ref.read(danbooruPostFetchTransformerProvider(config))(posts);
    },
    getSettings: () async => ref.read(settingsProvider),
  );
});

typedef PostFetchTransformer = Future<List<DanbooruPost>> Function(
    List<DanbooruPost> posts);

final danbooruPostFetchTransformerProvider =
    Provider.family<PostFetchTransformer, BooruConfig>((ref, config) {
  final booruUserIdentityProvider =
      ref.watch(booruUserIdentityProviderProvider(config));

  return (posts) async {
    final id = await booruUserIdentityProvider.getAccountIdFromConfig(config);
    if (id != null) {
      final ids = posts.map((e) => e.id).toList();

      ref.read(danbooruFavoritesProvider(config).notifier).checkFavorites(ids);
      ref.read(danbooruPostVotesProvider(config).notifier).getVotes(ids);
    }

    return Future.value(posts).then(filterFlashFiles());
  };
});

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterFlashFiles() => filterUnsupportedFormat({'swf'});

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterUnsupportedFormat(
  Set<String> fileExtensions,
) =>
        (posts) async => posts
            .where((e) => !fileExtensions.contains(e.format))
            .where((e) => !e.metaTags.contains('flash'))
            .toList();

final danbooruArtistCharacterPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfig>((ref, config) {
  final postRepo = ref.watch(danbooruPostRepoProvider(config));

  return DanbooruArtistCharacterPostRepository(
    repository: postRepo,
    cache: LruCacher(),
  );
});

final danbooruPostCountRepoProvider =
    Provider.family<PostCountRepository, BooruConfig>((ref, config) {
  return PostCountRepositoryBuilder(
    countTags: (tags) =>
        ref.read(danbooruClientProvider(config)).countPosts(tags: tags),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: config.url == kDanbooruSafeUrl ? ['rating:general'] : [],
  );
});
