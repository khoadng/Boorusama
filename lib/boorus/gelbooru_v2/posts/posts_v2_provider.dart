// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruV2PostRepoProvider =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfig>(
  (ref, config) {
    final client = ref.watch(gelbooruV2ClientProvider(config));

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
          .then((value) => value
              .map((e) => gelbooruV2PostDtoToGelbooruPost(
                    e,
                    PostMetadata(
                      page: page,
                      search: tags.join(' '),
                    ),
                  ))
              .toList()),
      getSettings: () async => ref.read(settingsProvider),
    );
  },
);

final gelbooruV2ArtistCharacterPostRepoProvider =
    Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    return PostRepositoryCacher(
      repository: ref.watch(gelbooruV2PostRepoProvider(config)),
      cache: LruCacher<String, List<Post>>(capacity: 100),
    );
  },
);

final gelbooruV2ChildPostsProvider = FutureProvider.autoDispose
    .family<List<GelbooruV2Post>, GelbooruV2Post>((ref, post) async {
  return ref
      .watch(gelbooruV2PostRepoProvider(ref.watchConfig))
      .getPostsFromTagWithBlacklist(
        tag: post.relationshipQuery,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfig).future),
      );
});
