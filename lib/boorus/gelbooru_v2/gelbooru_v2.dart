// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/feats/comments/comments_v2.dart';
import 'package:boorusama/boorus/gelbooru_v2/feats/posts/posts_v2.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v2_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';
import 'pages/create_gelbooru_v2_config_page.dart';
import 'pages/gelbooru_v2_artist_page.dart';
import 'pages/gelbooru_v2_home_page.dart';
import 'pages/gelbooru_v2_post_details_desktop_page.dart';
import 'pages/gelbooru_v2_post_details_page.dart';

const kGelbooruV2CustomDownloadFileNameFormat =
    '{id}_{md5:maxlength=8}.{extension}';

final gelbooruV2ClientProvider =
    Provider.family<GelbooruV2Client, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

  return GelbooruV2Client.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});

final gelbooruV2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(gelbooruV2ClientProvider(config));

  return AutocompleteRepositoryBuilder(
    autocomplete: (query) async {
      final dtos = await client.autocomplete(term: query, limit: 20);

      return dtos
          .map((e) {
            try {
              return AutocompleteData(
                type: e.type,
                label: e.label?.replaceAll('_', ' ') ?? '<empty>',
                value: e.value!,
                category: e.category?.toString(),
                postCount: e.postCount,
              );
            } catch (err) {
              return AutocompleteData.empty;
            }
          })
          .where((e) => e != AutocompleteData.empty)
          .toList();
    },
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
  );
});

final gelbooruV2TagsFromIdProvider =
    FutureProvider.autoDispose.family<List<Tag>, int>(
  (ref, id) async {
    final config = ref.watchConfig;
    final client = ref.watch(gelbooruV2ClientProvider(config));

    final data = await client.getTagsFromPostId(postId: id);

    return data
        .map((e) => Tag(
              name: e.name ?? '',
              category: intToTagCategory(e.type ?? 0),
              postCount: e.count ?? 0,
            ))
        .toList();
  },
);

final gelbooruV2ArtistPostRepo =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfig>((ref, config) {
  return PostRepositoryCacher(
    keyBuilder: (tags, page, {limit}) => '${tags.join('-')}_${page}_$limit',
    repository: ref.watch(gelbooruV2PostRepoProvider(config)),
    cache: LruCacher(capacity: 100),
  );
});

//FIXME: should be handle the same as Danbooru?
final gelbooruV2ArtistPostsProvider = FutureProvider.autoDispose
    .family<List<GelbooruV2Post>, String?>((ref, artistName) async {
  if (artistName == null) return [];
  final config = ref.watchConfig;

  final blacklistedTags = ref.watch(blacklistTagsProvider(config));

  final repo = ref.watch(gelbooruV2ArtistPostRepo(ref.watchConfig));
  final posts = await repo.getPostsFromTagsOrEmpty([artistName], 1);

  return filterTags(
    posts.take(30).where((e) => !e.isFlash).toList(),
    blacklistedTags,
  );
});

final gelbooruV2CharacterPostsProvider = FutureProvider.autoDispose
    .family<List<GelbooruV2Post>, String?>((ref, characterName) async {
  if (characterName == null) return [];
  final config = ref.watchConfig;

  final blacklistedTags = ref.watch(blacklistTagsProvider(config));

  final repo = ref.watch(gelbooruV2ArtistPostRepo(ref.watchConfig));
  final posts = await repo.getPostsFromTagsOrEmpty([characterName], 1);

  return filterTags(
    posts.take(30).where((e) => !e.isFlash).toList(),
    blacklistedTags,
  );
});

class GelbooruV2Builder
    with
        FavoriteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        NoteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        PostCountNotSupportedMixin,
        DefaultSortTokenToQueryMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultTagColorMixin
    implements BooruBuilder {
  GelbooruV2Builder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.client,
  });

  final PostRepository<GelbooruV2Post> postRepo;
  final AutocompleteRepository autocompleteRepo;
  final GelbooruV2Client client;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateGelbooruV2ConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat:
                  kGelbooruV2CustomDownloadFileNameFormat,
            ),
            backgroundColor: backgroundColor,
            isNewConfig: true,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => GelbooruV2HomePage(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateGelbooruV2ConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(
        tags,
        page,
      );

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  SearchPageBuilder get searchPageBuilder => (context, initialQuery) =>
      GelbooruV2SearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, booruConfig, payload) => payload.isDesktop
          ? GelbooruV2PostDetailsDesktopPage(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            )
          : GelbooruV2PostDetailsPage(
              posts: payload.posts.map((e) => e as GelbooruV2Post).toList(),
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => config.hasLoginDetails()
          ? GelbooruV2FavoritesPage(uid: config.login!)
          : const Scaffold(
              body: Center(
                child: Text(
                    'You need to provide login details to use this feature.'),
              ),
            );

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruV2ArtistPage(
            artistName: artistName,
          );

  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => GelbooruV2ArtistPage(
            artistName: characterName,
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => GelbooruV2CommentPage(
            postId: postId,
          );

  @override
  GranularRatingQueryBuilder? get granularRatingQueryBuilder =>
      (currentQuery, config) => switch (config.ratingFilter) {
            BooruConfigRatingFilter.none => currentQuery,
            BooruConfigRatingFilter.hideNSFW => [
                ...currentQuery,
                'rating:safe',
              ],
            BooruConfigRatingFilter.hideExplicit => [
                ...currentQuery,
                '-rating:explicit',
              ],
            BooruConfigRatingFilter.custom =>
              config.granularRatingFiltersWithoutUnknown.toOption().fold(
                    () => currentQuery,
                    (ratings) => [
                      ...currentQuery,
                      ...ratings.map((e) => '-rating:${e.toFullString(
                            legacy: true,
                          )}'),
                    ],
                  ),
          };

  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
      };

  @override
  DownloadFilenameGenerator get downloadFilenameBuilder =>
      DownloadFileNameBuilder(
        defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat:
            kGelbooruV2CustomDownloadFileNameFormat,
        sampleData: kDanbooruPostSamples,
        tokenHandlers: {
          'id': (post, config) => post.id.toString(),
          'tags': (post, config) => post.tags.join(' '),
          'extension': (post, config) =>
              extension(config.downloadUrl).substring(1),
          'width': (post, config) => post.width.toString(),
          'height': (post, config) => post.height.toString(),
          'mpixels': (post, config) => post.mpixels.toString(),
          'aspect_ratio': (post, config) => post.aspectRatio.toString(),
          'md5': (post, config) => post.md5,
          'source': (post, config) => config.downloadUrl,
          'rating': (post, config) => post.rating.name,
          'index': (post, config) => config.index?.toString(),
        },
      );

  @override
  SortTokenToQueryBuilder get sortTokenToQueryBuilder =>
      (token) => switch (token) {
            SortToken.newest => [],
            SortToken.popular => ['sort:score:desc'],
            SortToken.oldest => ['sort:id:asc'],
          };
}

class GelbooruV2SearchPage extends ConsumerWidget {
  const GelbooruV2SearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    return SearchPageScaffold(
      initialQuery: initialQuery,
      gridBuilder: (context, controller, slivers) => InfinitePostListScaffold(
        controller: controller,
        sliverHeaderBuilder: (context) => slivers,
      ),
      fetcher: (page, tags) =>
          ref.watch(gelbooruV2PostRepoProvider(config)).getPosts(tags, page),
    );
  }
}

class GelbooruV2CommentPage extends ConsumerWidget {
  const GelbooruV2CommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    return CommentPageScaffold(
      postId: postId,
      fetcher: (postId) =>
          ref.watch(gelbooruV2CommentRepoProvider(config)).getComments(postId),
    );
  }
}

class GelbooruV2FavoritesPage extends ConsumerWidget {
  const GelbooruV2FavoritesPage({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'fav:$uid';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(gelbooruV2PostRepoProvider(config)).getPosts([query], page),
    );
  }
}
