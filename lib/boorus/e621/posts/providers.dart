// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final e621PostRepoProvider =
    Provider.family<PostRepository<E621Post>, BooruConfigSearch>((ref, config) {
      final client = ref.watch(e621ClientProvider(config.auth));
      final tagComposer = ref.watch(legacyTagQueryComposerProvider(config));

      return PostRepositoryBuilder(
        tagComposer: tagComposer,
        fetchSingle: (id, {options}) async {
          final numericId = id as NumericPostId?;

          if (numericId == null) return Future.value(null);

          final post = await client.getPost(numericId.value);

          return post != null ? postDtoToPost(post, null) : null;
        },
        fetch: (tags, page, {limit, options}) async {
          final data = await client
              .getPosts(
                page: page,
                tags: tags,
                limit: limit,
              )
              .then(
                (value) => value
                    .map(
                      (e) => postDtoToPost(
                        e,
                        PostMetadata(
                          page: page,
                          search: tags.join(' '),
                          limit: limit,
                        ),
                      ),
                    )
                    .toList(),
              );

          if (options?.cascadeRequest ?? true) {
            ref.read(favoritesProvider(config.auth).notifier).preload(data);
          }

          return data.toResult();
        },
        getSettings: () async => ref.read(imageListingSettingsProvider),
      );
    });
