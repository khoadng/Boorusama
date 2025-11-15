// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final sankakuPseudoIdGeneratorProvider = Provider((ref) {
  return PostIdGenerator();
});

final sankakuPostRepoProvider =
    Provider.family<PostRepository<SankakuPost>, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(sankakuClientProvider(config.auth));
        final idGenerator = ref.watch(sankakuPseudoIdGeneratorProvider);
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          getSettings: () async => ref.read(imageListingSettingsProvider),
          fetchSingle: (id, {options}) async {
            final stringId = id as StringPostId?;

            if (stringId == null) return Future.value();

            final post = await client.getPost(id: stringId.value);

            return post != null ? postDtoToPost(post, idGenerator, null) : null;
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
                    idGenerator,
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

final sankakuUploaderQueryProvider =
    Provider.family<UploaderQuery?, SankakuPost>((ref, post) {
      return switch (post.uploaderName) {
        final uploader? => UserColonUploaderQuery(uploader),
        _ => null,
      };
    });
