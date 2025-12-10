// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/downloads/urls/types.dart';
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

final class DanbooruDownloadSource implements DownloadSourceProvider {
  const DanbooruDownloadSource();

  @override
  List<DownloadSource> getDownloadSources(BuildContext context, Post post) {
    return [
      if (post.thumbnailImageUrl.isNotEmpty)
        DownloadSource(
          url: post.thumbnailImageUrl,
          name: context.t.settings.download.qualities.preview,
        ),
      if (post case final DanbooruPost danPost
          when danPost.url180x180.isNotEmpty)
        DownloadSource(
          url: danPost.url180x180,
          name: '180x180',
        ),
      if (post case final DanbooruPost danPost
          when danPost.url360x360.isNotEmpty)
        DownloadSource(
          url: danPost.url360x360,
          name: '360x360',
        ),
      if (post case final DanbooruPost danPost
          when danPost.url720x720.isNotEmpty)
        DownloadSource(
          url: danPost.url720x720,
          name: '720x720',
        ),
      if (post.sampleImageUrl.isNotEmpty)
        DownloadSource(
          url: post.sampleImageUrl,
          name: context.t.settings.download.qualities.sample,
        ),
      if (post.originalImageUrl.isNotEmpty)
        DownloadSource(
          url: post.originalImageUrl,
          name: context.t.settings.download.qualities.original,
        ),
    ];
  }
}
