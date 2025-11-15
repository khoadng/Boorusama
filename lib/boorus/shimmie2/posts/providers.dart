// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../clients/providers.dart';
import 'parser.dart';
import 'types.dart';

final shimmie2PostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(shimmie2ClientProvider(config.auth));
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          fetchSingle: (id, {options}) {
            return Future.value();
          },
          fetch: (tags, page, {limit, options}) async {
            final useGraphQL = await ref.read(
              useGraphQLClientProvider(config.auth).future,
            );

            final posts = await client.getPosts(
              tags: tags,
              page: page,
              limit: limit,
              useGraphQL: useGraphQL,
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

final shimmie2UploaderQueryProvider =
    Provider.family<UploaderQuery?, Shimmie2Post>((ref, post) {
      return switch (post.uploaderName) {
        final uploader? => UserEqualsUploaderQuery(uploader),
        _ => null,
      };
    });
