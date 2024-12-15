// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/configs/config.dart';
import '../../core/foundation/path.dart';
import '../../core/http/providers.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/providers.dart';
import '../../core/settings/providers.dart';
import '../../core/tags/categories/tag_category.dart';
import '../../core/tags/tag/tag.dart';
import '../../core/utils/color_utils.dart';
import 'post_votes/post_votes.dart';
import 'szurubooru_post.dart';

final szurubooruClientProvider =
    Provider.family<SzurubooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));

    return SzurubooruClient(
      dio: dio,
      baseUrl: config.url,
      username: config.login,
      token: config.apiKey,
    );
  },
);

final szurubooruPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(szurubooruClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(currentTagQueryComposerProvider),
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        final categories =
            await ref.read(szurubooruTagCategoriesProvider(config.auth).future);

        final data = posts.posts
            .map(
              (e) => SzurubooruPost(
                id: e.id ?? 0,
                thumbnailImageUrl: e.thumbnailUrl ?? '',
                sampleImageUrl: e.contentUrl ?? '',
                originalImageUrl: e.contentUrl ?? '',
                tags:
                    e.tags?.map((e) => e.names?.firstOrNull).nonNulls.toSet() ??
                        {},
                tagDetails: e.tags
                        ?.map(
                          (e) => Tag(
                            name: e.names?.firstOrNull ?? '???',
                            category: categories.firstWhereOrNull(
                                  (element) => element.name == e.category,
                                ) ??
                                TagCategory.general(),
                            postCount: e.usages ?? 0,
                          ),
                        )
                        .toList() ??
                    [],
                rating: switch (e.safety?.toLowerCase()) {
                  'safe' => Rating.general,
                  'questionable' => Rating.questionable,
                  'sketchy' => Rating.questionable,
                  'unsafe' => Rating.explicit,
                  _ => Rating.general,
                },
                hasComment: (e.commentCount ?? 0) > 0,
                isTranslated: (e.noteCount ?? 0) > 0,
                hasParentOrChildren: (e.relationCount ?? 0) > 0,
                source: PostSource.from(e.source),
                score: e.score ?? 0,
                duration: 0,
                fileSize: e.fileSize ?? 0,
                format: extension(e.contentUrl ?? ''),
                hasSound: e.flags?.contains('sound'),
                height: e.canvasHeight?.toDouble() ?? 0,
                md5: e.checksumMD5 ?? '',
                videoThumbnailUrl: e.thumbnailUrl ?? '',
                videoUrl: e.contentUrl ?? '',
                width: e.canvasWidth?.toDouble() ?? 0,
                createdAt: e.creationTime != null
                    ? DateTime.tryParse(e.creationTime!)
                    : null,
                uploaderName: e.user?.name,
                ownFavorite: e.ownFavorite ?? false,
                favoriteCount: e.favoriteCount ?? 0,
                commentCount: e.commentCount ?? 0,
                metadata: PostMetadata(
                  page: page,
                  search: tags.join(' '),
                ),
              ),
            )
            .toList();

        ref.read(favoritesProvider(config.auth).notifier).preload(data);
        ref
            .read(szurubooruPostVotesProvider(config.auth).notifier)
            .getVotes(data);

        return data.toResult(
          total: posts.total,
        );
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);

final szurubooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(szurubooruClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        // if not logged in, don't autocomplete
        if (!config.hasLoginDetails()) return [];

        final tags = await client.autocomplete(query: query);

        final categories =
            await ref.read(szurubooruTagCategoriesProvider(config).future);

        return tags
            .map(
              (e) => AutocompleteData(
                label:
                    e.names?.firstOrNull?.toLowerCase().replaceAll('_', ' ') ??
                        '???',
                value: e.names?.firstOrNull?.toLowerCase() ?? '???',
                category: categories
                    .firstWhereOrNull((element) => element.name == e.category)
                    ?.name,
                postCount: e.usages,
              ),
            )
            .toList();
      },
    );
  },
);

final szurubooruTagCategoriesProvider =
    FutureProvider.family<List<TagCategory>, BooruConfigAuth>(
  (ref, config) async {
    final client = ref.read(szurubooruClientProvider(config));

    final categories = await client.getTagCategories();

    return categories
        .mapIndexed(
          (index, e) => TagCategory(
            id: index,
            name: e.name ?? '???',
            order: e.order,
            darkColor: ColorUtils.hexToColor(e.color),
            lightColor: ColorUtils.hexToColor(e.color),
          ),
        )
        .toList();
  },
);

class SzurubooruFavoriteRepository extends FavoriteRepository<SzurubooruPost> {
  SzurubooruFavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  SzurubooruClient get client => ref.read(szurubooruClientProvider(config));

  @override
  bool canFavorite() => config.hasLoginDetails();

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async {
    try {
      await client.addToFavorites(postId: postId);

      await ref
          .read(szurubooruPostVotesProvider(config).notifier)
          .upvote(postId, localOnly: true);

      return AddFavoriteStatus.success;
    } catch (e) {
      return AddFavoriteStatus.failure;
    }
  }

  @override
  Future<bool> removeFromFavorites(int postId) async =>
      client.removeFromFavorites(postId: postId).then((value) => true);

  @override
  bool isPostFavorited(SzurubooruPost post) => post.ownFavorite;
}
