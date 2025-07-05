// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import 'parser.dart';

final animePicturesPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(animePicturesClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(tagQueryComposerProvider(config)),
      fetchSingle: (id, {options}) {
        final numericId = id as NumericPostId?;

        if (numericId == null) return Future.value(null);

        return client.getPostDetails(id: numericId.value).then(
          (e) {
            final post = e.post;
            return post != null ? dtoToAnimePicturesPost(post) : null;
          },
        );
      },
      fetch: (tags, page, {limit, options}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        return posts
            .map(
              (e) => dtoToAnimePicturesPost(
                e,
                metadata: PostMetadata(
                  page: page,
                  search: tags.join(' '),
                  limit: limit,
                ),
              ),
            )
            .toList()
            .toResult();
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);

final postDetailsProvider = FutureProvider.autoDispose
    .family<PostDetailsDto, (BooruConfigAuth, int)>((ref, params) async {
  ref.cacheFor(const Duration(seconds: 30));

  final (config, id) = params;

  final client = ref.watch(animePicturesClientProvider(config));

  final post = await client.getPostDetails(id: id);

  return post;
});
