// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/search/query_composer_providers.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruPostRepoProvider =
    Provider.family<PostRepository<GelbooruPost>, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(currentTagQueryComposerProvider),
      fetch: client.getPostResults,
      fetchFromController: (controller, page, {limit}) {
        final tags = controller.tags.map((e) => e.originalTag).toList();

        return client.getPostResults(tags, page, limit: limit);
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);

final gelbooruArtistCharacterPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    return PostRepositoryCacher(
      repository: ref.watch(gelbooruPostRepoProvider(config)),
      cache: LruCacher<String, List<Post>>(capacity: 100),
    );
  },
);

extension GelbooruClientX on GelbooruClient {
  Future<PostResult<GelbooruPost>> getPostResults(
    List<String> tags,
    int page, {
    int? limit,
  }) =>
      getPosts(
        tags: tags,
        page: page,
        limit: limit,
      ).then((value) => value.posts
          .map((e) => gelbooruPostDtoToGelbooruPost(
                e,
                PostMetadata(
                  page: page,
                  search: tags.join(' '),
                ),
              ))
          .toList()
          .toResult(total: value.count));
}
