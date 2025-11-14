// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/favorites/providers.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/posts/post/types.dart';
import '../../../../../core/settings/providers.dart';
import '../../../client_provider.dart';
import '../../../tags/_shared/tag_list_notifier.dart';
import '../../../tags/tag/providers.dart';
import '../../../users/user/providers.dart';
import '../../votes/providers.dart';
import 'converter.dart';
import 'danbooru_post.dart';

final danbooruPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfigSearch>((
      ref,
      config,
    ) {
      final client = ref.watch(danbooruClientProvider(config.auth));
      final tagComposer = ref.watch(danbooruTagQueryComposerProvider(config));

      return PostRepositoryBuilder(
        tagComposer: tagComposer,
        fetchSingle: (id, {options}) async {
          final numericId = id as NumericPostId?;

          if (numericId == null) return Future.value();

          final post = await client.getPost(numericId.value);

          return post != null ? postDtoToPost(post, null) : null;
        },
        fetch: (tags, page, {limit, options}) async {
          final posts = await client
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
                    .toList(),
              );

          return (options?.cascadeRequest ?? true)
              ? transformPosts(ref, posts.toResult(), config)
              : posts.toResult();
        },
        getSettings: () async => ref.read(imageListingSettingsProvider),
      );
    });

typedef PostFetchTransformer =
    Future<PostResult<DanbooruPost>> Function(
      PostResult<DanbooruPost> posts,
    );

Future<PostResult<DanbooruPost>> transformPosts(
  Ref ref,
  PostResult<DanbooruPost> r,
  BooruConfigSearch config,
) async {
  final posts = _filter(
    r.posts,
    config.filter.bannedPostVisibility.isHidden,
  );

  final user = await ref.read(danbooruCurrentUserProvider(config.auth).future);

  if (user != null) {
    final ids = posts.map((e) => e.id).toList();

    unawaited(
      ref.read(favoritesProvider(config.auth).notifier).checkFavorites(ids),
    );
    unawaited(
      ref.read(danbooruPostVotesProvider(config.auth).notifier).getVotes(posts),
    );
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
