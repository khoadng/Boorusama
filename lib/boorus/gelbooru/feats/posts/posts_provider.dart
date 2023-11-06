// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruPostRepoProvider =
    Provider.family<PostRepository<GelbooruPost>, BooruConfig>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config));

    getTags(List<String> tags) {
      final tag = booruFilterConfigToGelbooruTag(config.ratingFilter);

      return [
        ...tags,
        if (tag != null) tag,
      ];
    }

    return PostRepositoryBuilder(
      fetch: (tags, page, {limit}) => client
          .getPosts(
            tags: getTags(tags),
            page: page,
            limit: limit,
          )
          .then((value) =>
              value.posts.map(gelbooruPostDtoToGelbooruPost).toList()),
      getSettings: () async => ref.read(settingsProvider),
    );
  },
);

final gelbooruArtistCharacterPostRepoProvider =
    Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    return PostRepositoryCacher(
      repository: ref.watch(gelbooruPostRepoProvider(config)),
      cache: LruCacher<String, List<Post>>(capacity: 100),
    );
  },
);

String? booruFilterConfigToGelbooruTag(BooruConfigRatingFilter? filter) =>
    switch (filter) {
      BooruConfigRatingFilter.none || null => null,
      BooruConfigRatingFilter.hideExplicit => '-rating:explicit',
      BooruConfigRatingFilter.hideNSFW => 'rating:general',
    };
