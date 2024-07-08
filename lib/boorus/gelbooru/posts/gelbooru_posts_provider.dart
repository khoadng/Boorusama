// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruPostRepoProvider =
    Provider.family<PostRepository<GelbooruPost>, BooruConfig>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config));

    return PostRepositoryBuilder(
      fetch: (tags, page, {limit}) => client
          .getPosts(
            tags: getTags(
              config,
              tags,
              granularRatingQueries: (tags) => ref
                  .readCurrentBooruBuilder()
                  ?.granularRatingQueryBuilder
                  ?.call(tags, config),
            ),
            page: page,
            limit: limit,
          )
          .then((value) => value.posts
              .map((e) => gelbooruPostDtoToGelbooruPost(
                    e,
                    PostMetadata(
                      page: page,
                      search: tags.join(' '),
                    ),
                  ))
              .toList()),
      getSettings: () async => ref.read(imageListingSettingsProvider),
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
