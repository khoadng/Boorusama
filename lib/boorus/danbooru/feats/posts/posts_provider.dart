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

final danbooruPostRepoProvider = Provider<PostRepository<DanbooruPost>>((ref) {
  final client = ref.watch(danbooruClientProvider);

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
    Provider<PostRepository<DanbooruPost>>((ref) {
  final postRepo = ref.watch(danbooruPostRepoProvider);

  return DanbooruArtistCharacterPostRepository(
    repository: postRepo,
    cache: LruCacher(),
  );
});

final danbooruPostCountRepoProvider = Provider<PostCountRepository>((ref) {
  return PostCountRepositoryBuilder(
    countTags: (tags) =>
        ref.watch(danbooruClientProvider).countPosts(tags: tags),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: ref.watch(currentBooruConfigProvider).url == kDanbooruSafeUrl
        ? ['rating:general']
        : [],
  );
});
