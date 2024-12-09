// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/search/query_composer_providers.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import '../../../tags/shared/tag_list_notifier.dart';
import '../../../users/user/providers.dart';
import '../../favorites/providers.dart';
import '../../votes/providers.dart';
import 'converter.dart';
import 'danbooru_post.dart';

final danbooruPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfigSearch>(
        (ref, config) {
  final client = ref.watch(danbooruClientProvider(config.auth));

  return PostRepositoryBuilder(
    getComposer: () => ref.read(currentTagQueryComposerProvider),
    fetch: (tags, page, {limit}) async {
      final posts = await client
          .getPosts(
            page: page,
            tags: tags,
            limit: limit,
          )
          .then((value) => value
              .map((e) => postDtoToPost(
                    e,
                    PostMetadata(
                      page: page,
                      search: tags.join(' '),
                    ),
                  ))
              .toList());

      return transformPosts(ref, posts.toResult(), config);
    },
    getSettings: () async => ref.read(imageListingSettingsProvider),
  );
});

typedef PostFetchTransformer = Future<PostResult<DanbooruPost>> Function(
    PostResult<DanbooruPost> posts);

Future<PostResult<DanbooruPost>> transformPosts(
  Ref ref,
  PostResult<DanbooruPost> r,
  BooruConfigSearch config,
) async {
  final posts = _filter(
    r.posts,
    config.filter.hideBannedPosts,
  );

  final user = await ref.read(danbooruCurrentUserProvider(config.auth).future);

  if (user != null) {
    final ids = posts.map((e) => e.id).toList();

    ref
        .read(danbooruFavoritesProvider(config.auth).notifier)
        .checkFavorites(ids);
    ref.read(danbooruPostVotesProvider(config.auth).notifier).getVotes(posts);
    ref.read(danbooruTagListProvider(config.auth).notifier).removeTags(ids);
  }

  return r.copyWith(
    posts: posts,
  );
}

List<DanbooruPost> _filter(List<DanbooruPost> posts, bool hideBannedPosts) {
  posts.removeWhere(
    (e) =>
        (hideBannedPosts && e.isBanned) ||
        (e.format == 'swf' || e.format == '.swf') ||
        e.metaTags.contains('flash'),
  );

  return posts;
}
