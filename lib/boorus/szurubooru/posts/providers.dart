// Dart imports:
import 'dart:async';

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
import '../post_votes/providers.dart';
import '../tags/providers.dart';
import 'parser.dart';

final szurubooruPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(szurubooruClientProvider(config.auth));

        return PostRepositoryBuilder(
          getComposer: () => ref.read(tagQueryComposerProvider(config)),
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value(null);

            final post = await client.getPost(numericId.value);

            if (post == null) return null;

            final categories = await ref.read(
              szurubooruTagCategoriesProvider(config.auth).future,
            );

            return postDtoToPost(post, null, categories);
          },
          fetch: (tags, page, {limit, options}) async {
            final posts = await client.getPosts(
              tags: tags,
              page: page,
              limit: limit,
            );

            final categories = await ref.read(
              szurubooruTagCategoriesProvider(config.auth).future,
            );

            final data = posts.posts
                .map(
                  (e) => postDtoToPost(
                    e,
                    PostMetadata(
                      page: page,
                      search: tags.join(' '),
                      limit: limit,
                    ),
                    categories,
                  ),
                )
                .toList();

            if (options?.cascadeRequest ?? true) {
              ref.read(favoritesProvider(config.auth).notifier).preload(data);
              unawaited(
                ref
                    .read(szurubooruPostVotesProvider(config.auth).notifier)
                    .getVotes(data),
              );
            }

            return data.toResult(
              total: posts.total,
            );
          },
          getSettings: () async => ref.read(imageListingSettingsProvider),
        );
      },
    );
