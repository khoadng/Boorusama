// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/blacklists/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/settings/providers.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import '../gelbooru_v2.dart';
import '../gelbooru_v2_repository.dart';
import '../tags/providers.dart';
import 'parser.dart';
import 'types.dart';

final gelbooruV2PostRepoProvider =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(gelbooruV2ClientProvider(config.auth));
        final tagComposer = ref.watch(
          gelbooruV2TagQueryComposerProvider(config),
        );
        final imageUrlResolver = ref.watch(
          gelbooruV2PostImageUrlResolverProvider,
        );

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          fetch: (tags, page, {limit, options}) => client.getPostResults(
            tags,
            page,
            imageUrlResolver: imageUrlResolver,
            limit: limit,
            options: options,
          ),
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value(null);

            final post = await client.getPost(numericId.value);

            return post != null
                ? gelbooruV2PostDtoToGelbooruPost(post, null, imageUrlResolver)
                : null;
          },
          fetchFromController: (controller, page, {limit, options}) {
            final tags = controller.tags.map((e) => e.originalTag).toList();

            final newTags = tagComposer.compose(tags);

            return client.getPostResults(
              newTags,
              page,
              limit: limit,
              imageUrlResolver: imageUrlResolver,
              options: options,
            );
          },
          getSettings: () async => ref.read(imageListingSettingsProvider),
        );
      },
    );

final gelbooruV2PostProvider =
    FutureProvider.family<Post?, (PostId, BooruConfigSearch)>((
      ref,
      params,
    ) async {
      final (id, config) = params;
      final gelbooruV2 = ref.watch(gelbooruV2Provider);
      final cacheDuration = gelbooruV2
          .getCapabilitiesForSite(config.auth.url)
          ?.post
          ?.cacheSeconds;

      if (cacheDuration != null && cacheDuration > 0) {
        ref.cacheFor(Duration(seconds: cacheDuration));
      }

      final postRepo = ref.watch(gelbooruV2PostRepoProvider(config));

      final result = await postRepo.getPost(id).run();

      return result.getOrElse((_) => null);
    });

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

final gelbooruV2PostImageUrlResolverProvider =
    Provider<GelbooruV2ImageUrlResolver>(
      (ref) => const GelbooruV2ImageUrlResolver(),
    );

extension GelbooruV2ClientX on GelbooruV2Client {
  Future<PostResult<GelbooruV2Post>> getPostResults(
    List<String> tags,
    int page, {
    required GelbooruV2ImageUrlResolver imageUrlResolver,
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
            imageUrlResolver,
          ),
        )
        .toList()
        .toResult(total: posts.count);
  }
}
