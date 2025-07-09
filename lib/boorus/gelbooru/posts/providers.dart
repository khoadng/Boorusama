// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../../../foundation/caching/lru_cacher.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final gelbooruPostRepoProvider =
    Provider.family<PostRepository<GelbooruPost>, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(gelbooruClientProvider(config.auth));

        return PostRepositoryBuilder(
          getComposer: () => ref.read(tagQueryComposerProvider(config)),
          fetch: client.getPostResults,
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value(null);

            final post = await client.getPost(numericId.value);

            return post != null
                ? gelbooruPostDtoToGelbooruPost(post, null)
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
    PostFetchOptions? options,
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
                  limit: limit,
                ),
              ),
            )
            .toList()
            .toResult(total: value.count),
      );
}
