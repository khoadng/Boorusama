// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/search/query_composer_providers.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruV2PostRepoProvider =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(gelbooruV2ClientProvider(config.auth));

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

final gelbooruV2ArtistCharacterPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
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
      .watch(gelbooruV2PostRepoProvider(ref.watchConfigSearch))
      .getPostsFromTagWithBlacklist(
        tag: post.relationshipQuery,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfigAuth).future),
      );
});

extension GelbooruV2ClientX on GelbooruV2Client {
  Future<PostResult<GelbooruV2Post>> getPostResults(
    List<String> tags,
    int page, {
    int? limit,
  }) async {
    final posts = await getPosts(
      tags: tags,
      page: page,
      limit: limit,
    );

    return posts
        .map((e) => gelbooruV2PostDtoToGelbooruPost(
              e,
              PostMetadata(
                page: page,
                search: tags.join(' '),
              ),
            ))
        .toList()
        .toResult();
  }
}
