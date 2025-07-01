// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/search/queries/providers.dart';
import '../../../../../core/settings/providers.dart';
import '../../../moebooru_provider.dart';
import '../types/moebooru_popular_repository.dart';
import '../types/moebooru_post.dart';
import 'moebooru_popular_repository_api.dart';
import 'post_parser.dart';

final moebooruPostRepoProvider =
    Provider.family<PostRepository<MoebooruPost>, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(moebooruClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(tagQueryComposerProvider(config)),
      fetchSingle: (id, {options}) async {
        final numericId = id as NumericPostId?;

        if (numericId == null) return Future.value(null);

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

final moebooruPopularRepoProvider =
    Provider.family<MoebooruPopularRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(moebooruClientProvider(config));

    return MoebooruPopularRepositoryApi(
      client,
      config,
    );
  },
);
