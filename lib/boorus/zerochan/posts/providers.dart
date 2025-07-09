// Package imports:
import 'package:booru_clients/zerochan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';

final zerochanPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(zerochanClientProvider(config.auth));

        return PostRepositoryBuilder(
          getComposer: () => ref.read(tagQueryComposerProvider(config)),
          getSettings: () async => ref.read(imageListingSettingsProvider),
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value(null);

            final post = await client.getPost(id: numericId.value);

            return post != null ? postDtoToPost(post, null) : null;
          },
          fetch: (tags, page, {limit, options}) async {
            final posts = await client.getPosts(
              tags: tags,
              page: page,
              sort: ZerochanSortOrder.recency,
              limit: limit,
            );

            return posts
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
                .toList()
                .toResult();
          },
        );
      },
    );
