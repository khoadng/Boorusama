// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v2_client.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruV2PostRepoProvider =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfig>(
  (ref, config) {
    final client = ref.watch(gelbooruV2ClientProvider(config));
    final composer = ref.watch(tagQueryComposerProvider(config));

    return PostRepositoryBuilder(
      tagComposer: composer,
      fetch: client.getPostResults,
      fetchFromController: (controller, page, {limit}) {
        final tags = controller.tags.map((e) => e.originalTag).toList();

        final newTags = composer.compose(tags);

        return client.getPostResults(newTags, page, limit: limit);
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
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
