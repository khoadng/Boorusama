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

final shimmie2PostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(shimmie2ClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(tagQueryComposerProvider(config)),
      fetchSingle: (id, {options}) {
        return Future.value(null);
      },
      fetch: (tags, page, {limit, options}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
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
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);
