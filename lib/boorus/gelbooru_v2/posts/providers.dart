// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/blacklists/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../../../foundation/caching/lru_cacher.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final gelbooruV2PostRepoProvider =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(gelbooruV2ClientProvider(config.auth));

        return PostRepositoryBuilder(
          getComposer: () => ref.read(tagQueryComposerProvider(config)),
          fetch: client.getPostResults,
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value(null);

            final post = await client.getPost(numericId.value);

            return post != null
                ? gelbooruV2PostDtoToGelbooruPost(post, null)
                : null;
          },
          fetchFromController: (controller, page, {limit, options}) {
            final tags = controller.tags.map((e) => e.originalTag).toList();

            final newTags = ref
                .read(tagQueryComposerProvider(config))
                .compose(tags);

            return client.getPostResults(newTags, page, limit: limit);
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
    .family<
      List<GelbooruV2Post>,
      (BooruConfigFilter, BooruConfigSearch, GelbooruV2Post)
    >((ref, params) async {
      final (filter, search, post) = params;

      return ref
          .watch(gelbooruV2PostRepoProvider(search))
          .getPostsFromTagWithBlacklist(
            tag: post.relationshipQuery,
            blacklist: ref.watch(blacklistTagsProvider(filter).future),
          );
    });

extension GelbooruV2ClientX on GelbooruV2Client {
  Future<PostResult<GelbooruV2Post>> getPostResults(
    List<String> tags,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) async {
    final posts = await getPosts(
      tags: tags,
      page: page,
      limit: limit,
    );

    return posts.posts
        .map(
          (e) => gelbooruV2PostDtoToGelbooruPost(
            e,
            PostMetadata(
              page: page,
              search: tags.join(' '),
              limit: limit,
            ),
          ),
        )
        .toList()
        .toResult(total: posts.count);
  }
}
