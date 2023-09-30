// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final danbooruPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return PostRepositoryBuilder(
    fetch: (tags, page, {limit}) => client
        .getPosts(
          page: page,
          tags: tags,
          limit: limit,
        )
        .then((value) => value.map(postDtoToPost).toList()),
    getSettings: () async => ref.read(settingsProvider),
  );
});

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
