// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';

final sizebooruPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(sizebooruClientProvider(config.auth));
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          getSettings: () async => ref.read(imageListingSettingsProvider),
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;
            if (numericId == null) return Future.value();

            final post = await client.getPost(numericId.value);
            return post != null ? dtoToSizebooruPost(post, null) : null;
          },
          fetch: (tags, page, {limit, options}) async {
            final posts = await client.getPosts(
              tags: tags,
              page: page,
              limit: limit,
            );

            return posts
                .map(
                  (e) => dtoToSizebooruPost(
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
