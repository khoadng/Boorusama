// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/blacklists/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/foundation/caching/lru_cacher.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/query_composer_providers.dart';
import '../../../core/settings/providers.dart';
import '../gelbooru_v2.dart';
import 'posts_v2.dart';

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
        .map(
          (e) => gelbooruV2PostDtoToGelbooruPost(
            e,
            PostMetadata(
              page: page,
              search: tags.join(' '),
            ),
          ),
        )
        .toList()
        .toResult();
  }
}
