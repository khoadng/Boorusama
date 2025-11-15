// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/blacklists/providers.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/settings/providers.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import '../gelbooru_v2_provider.dart';
import '../tags/providers.dart';
import 'repo.dart';
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

        return GelbooruV2PostRepository(
          fetcher: (tags, page, {limit, options}) => client.getPosts(
            page: page,
            tags: tags,
            limit: limit,
          ),
          fetchSingle: (id, {options}) => client.getPost(id),
          imageUrlResolver: imageUrlResolver,
          tagComposer: tagComposer,
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
    >((ref, params) {
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

final gelbooruV2UploaderQueryProvider =
    Provider.family<UploaderQuery?, GelbooruV2Post>((ref, post) {
      return switch (post.uploaderName) {
        final uploader? => UserColonUploaderQuery(uploader),
        _ => null,
      };
    });
