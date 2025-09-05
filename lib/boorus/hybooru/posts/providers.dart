// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';

final hybooruPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(hybooruClientProvider(config.auth));
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value();

            final post = await client.getPost(id: numericId.value);
            return post != null
                ? postDtoToPost(post, null, config.auth.url)
                : null;
          },
          fetch: (tags, page, {limit, options}) async {
            final query = tags.isNotEmpty ? tags.join(' ') : null;
            final posts = await client.getPosts(
              query: query,
              page: page - 1,
              pageSize: limit,
            );
            return posts.posts
                .map(
                  (e) => postSummaryToPost(
                    e,
                    PostMetadata(
                      page: page,
                      search: tags.join(' '),
                      limit: limit,
                    ),
                    config.auth.url,
                  ),
                )
                .toList()
                .toResult();
          },
          getSettings: () async => ref.read(imageListingSettingsProvider),
        );
      },
    );
