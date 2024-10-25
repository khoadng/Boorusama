// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import '../post_votes/post_votes.dart';
import '../users/users.dart';

final danbooruPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return PostRepositoryBuilder(
    tagComposer: ref.watch(tagQueryComposerProvider(config)),
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

      return ref
          .read(danbooruPostFetchTransformerProvider(config))(posts.toResult());
    },
    getSettings: () async => ref.read(imageListingSettingsProvider),
  );
});

final danbooruPostCreateProvider = AsyncNotifierProvider.autoDispose
    .family<DanbooruPostCreateNotifier, DanbooruPost?, BooruConfig>(
        DanbooruPostCreateNotifier.new);

class DanbooruPostCreateNotifier
    extends AutoDisposeFamilyAsyncNotifier<DanbooruPost?, BooruConfig> {
  @override
  FutureOr<DanbooruPost?> build(BooruConfig arg) {
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

final danbooruPostFetchTransformerProvider =
    Provider.family<PostFetchTransformer, BooruConfig>((ref, config) {
  return (r) async {
    final posts = _filter(
      r.posts,
      config.hideBannedPosts,
    );

    final user = await ref.read(danbooruCurrentUserProvider(config).future);

    if (user != null) {
      final ids = posts.map((e) => e.id).toList();

      ref.read(danbooruFavoritesProvider(config).notifier).checkFavorites(ids);
      ref.read(danbooruPostVotesProvider(config).notifier).getVotes(posts);
      ref.read(danbooruTagListProvider(config).notifier).removeTags(ids);
    }

    return r.copyWith(
      posts: posts,
    );
  };
});

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
    Provider.family<PostCountRepository, BooruConfig>((ref, config) {
  return PostCountRepositoryBuilder(
    countTags: (tags) =>
        ref.read(danbooruClientProvider(config)).countPosts(tags: tags),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: config.url == kDanbooruSafeUrl ? ['rating:g'] : [],
  );
});
