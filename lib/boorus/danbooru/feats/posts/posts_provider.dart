// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';
import '../users/users.dart';

final danbooruPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return PostRepositoryBuilder(
    fetch: (tags, page, {limit}) async {
      final posts = await client
          .getPosts(
            page: page,
            tags: getTags(
              config,
              tags,
              granularRatingQueries: (tags) => ref
                  .readCurrentBooruBuilder()
                  ?.granularRatingQueryBuilder
                  ?.call(tags, config),
            ),
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
    final user = await ref.read(danbooruCurrentUserProvider(config).future);

    if (user != null) {
      final ids = r.posts.map((e) => e.id).toList();

      ref.read(danbooruFavoritesProvider(config).notifier).checkFavorites(ids);
      ref.read(danbooruPostVotesProvider(config).notifier).getVotes(ids);
      ref.read(danbooruTagListProvider(config).notifier).removeTags(ids);
    }

    final value = await Future.value(r.posts).then(filterFlashFiles());

    return r.copyWith(posts: value);
  };
});

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterFlashFiles() => filterUnsupportedFormat({'swf'});

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterUnsupportedFormat(
  Set<String> fileExtensions,
) =>
        (posts) async => posts
            .where((e) => !fileExtensions.contains(e.format))
            .where((e) => !e.metaTags.contains('flash'))
            .toList();

final danbooruArtistCharacterPostRepoProvider =
    Provider.family<PostRepository<DanbooruPost>, BooruConfig>((ref, config) {
  final postRepo = ref.watch(danbooruPostRepoProvider(config));

  return DanbooruArtistCharacterPostRepository(
    repository: postRepo,
    cache: LruCacher(),
  );
});

final danbooruPostCountRepoProvider =
    Provider.family<PostCountRepository, BooruConfig>((ref, config) {
  return PostCountRepositoryBuilder(
    countTags: (tags) =>
        ref.read(danbooruClientProvider(config)).countPosts(tags: tags),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: config.url == kDanbooruSafeUrl ? ['rating:general'] : [],
  );
});
