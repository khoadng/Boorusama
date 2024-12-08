// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites_notifier.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/count.dart';
import 'package:boorusama/core/search/query_composer_providers.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import '../../tags/shared/tag_list_notifier.dart';
import '../../users/user/providers.dart';
import '../votes/post_votes_notifier.dart';
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

final danbooruPostCreateProvider = AsyncNotifierProvider.autoDispose
    .family<DanbooruPostCreateNotifier, DanbooruPost?, BooruConfigAuth>(
        DanbooruPostCreateNotifier.new);

class DanbooruPostCreateNotifier
    extends AutoDisposeFamilyAsyncNotifier<DanbooruPost?, BooruConfigAuth> {
  @override
  FutureOr<DanbooruPost?> build(BooruConfigAuth arg) {
    return null;
  }

  Future<void> create({
    required int mediaAssetId,
    required int uploadMediaAssetId,
    required Rating rating,
    required String source,
    required List<String> tags,
    String? artistCommentaryTitle,
    String? artistCommentaryDesc,
    String? translatedCommentaryTitle,
    String? translatedCommentaryDesc,
    int? parentId,
  }) async {
    final client = ref.read(danbooruClientProvider(arg));

    state = const AsyncLoading();

    try {
      final post = await client.createPost(
        mediaAssetId: mediaAssetId,
        uploadMediaAssetId: uploadMediaAssetId,
        rating: rating.toShortString(),
        source: source,
        tags: tags,
        artistCommentaryTitle: artistCommentaryTitle,
        artistCommentaryDesc: artistCommentaryDesc,
        translatedCommentaryTitle: translatedCommentaryTitle,
        translatedCommentaryDesc: translatedCommentaryDesc,
        parentId: parentId,
      );

      state = AsyncData(postDtoToPostNoMetadata(post));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

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

final danbooruPostCountRepoProvider =
    Provider.family<PostCountRepository, BooruConfigSearch>((ref, config) {
  return PostCountRepositoryBuilder(
    countTags: (tags) =>
        ref.read(danbooruClientProvider(config.auth)).countPosts(tags: tags),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: config.auth.url == kDanbooruSafeUrl ? ['rating:g'] : [],
  );
});
