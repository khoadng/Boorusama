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
import 'types.dart';

final moebooruPostRepoProvider =
    Provider.family<PostRepository<MoebooruPost>, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(moebooruClientProvider(config.auth));
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value();

            final post = await client.getPost(numericId.value);

            return post != null ? postDtoToPost(post, null) : null;
          },
          fetch: (tags, page, {limit, options}) => client
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
                    .toList()
                    .toResult(),
              ),
          getSettings: () async => ref.read(imageListingSettingsProvider),
        );
      },
    );
