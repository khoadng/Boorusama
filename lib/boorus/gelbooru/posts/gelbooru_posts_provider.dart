// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/search/query_composer_providers.dart';
import '../../../core/settings/data/listing_provider.dart';
import '../../../foundation/caching/lru_cacher.dart';
import '../gelbooru.dart';

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
      ).then(
        (value) => value.posts
            .map(
              (e) => gelbooruPostDtoToGelbooruPost(
                e,
                PostMetadata(
                  page: page,
                  search: tags.join(' '),
                ),
              ),
            )
            .toList()
            .toResult(total: value.count),
      );
}
