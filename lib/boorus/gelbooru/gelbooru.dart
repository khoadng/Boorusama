// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart';
import 'pages/create_gelbooru_config_page.dart';
import 'pages/gelbooru_artist_page.dart';
import 'pages/gelbooru_home_page.dart';
import 'pages/gelbooru_post_details_desktop_page.dart';
import 'pages/gelbooru_post_details_page.dart';

const kGelbooruCustomDownloadFileNameFormat =
    '{id}_{md5:maxlength=8}.{extension}';

final gelbooruClientProvider =
    Provider.family<GelbooruClient, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

  return GelbooruClient.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});

final gelbooruTagRepoProvider = Provider.family<TagRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config));

    return TagRepositoryBuilder(
      persistentStorageKey: '${Uri.encodeComponent(config.url)}_tags_cache_v1',
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTags(
          page: page,
          tags: tags,
        );

        return data
            .map((e) => Tag(
                  name: e.name ?? '',
                  category: intToTagCategory(e.type ?? 0),
                  postCount: e.count ?? 0,
                ))
            .toList();
      },
    );
  },
);

final gelbooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(gelbooruClientProvider(config));

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
    final client = ref.watch(gelbooruClientProvider(config));

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

final gelbooruArtistPostRepo =
    Provider.family<PostRepository<GelbooruPost>, BooruConfig>((ref, config) {
  return PostRepositoryCacher(
    keyBuilder: (tags, page, {limit}) => '${tags.join('-')}_${page}_$limit',
    repository: ref.watch(gelbooruPostRepoProvider(config)),
    cache: LruCacher(capacity: 100),
  );
});

//FIXME: should be handle the same as Danbooru?
final gelbooruArtistPostsProvider = FutureProvider.autoDispose
    .family<List<GelbooruPost>, String?>((ref, artistName) async {
  if (artistName == null) return [];

  final globalBlacklistedTags = ref.watch(globalBlacklistedTagsProvider);

  final repo = ref.watch(gelbooruArtistPostRepo(ref.watchConfig));
  final posts = await repo.getPostsFromTagsOrEmpty([artistName], 1);

  return filterTags(
    posts.take(30).where((e) => !e.isFlash).toList(),
    {
      ...globalBlacklistedTags.map((e) => e.name),
    },
  );
});

class GelbooruBuilder
    with
        FavoriteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        NoteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultTagColorMixin
    implements BooruBuilder {
  GelbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.client,
  });

  final PostRepository<GelbooruPost> postRepo;
  final AutocompleteRepository autocompleteRepo;
  final GelbooruClient client;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateGelbooruConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat:
                  kGelbooruCustomDownloadFileNameFormat,
            ),
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => GelbooruHomePage(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateGelbooruConfigPage(
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
  PostCountFetcher? get postCountFetcher => (config, tags) {
        final tag = booruFilterConfigToGelbooruTag(config.ratingFilter);

        return client.getPosts(
          tags: [
            ...tags,
            if (tag != null) tag,
          ],
        ).then((value) => value.count);
      };

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, booruConfig, payload) => payload.isDesktop
          ? GelbooruPostDetailsDesktopPage(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              hasDetailsTagList: booruConfig.booruType.supportTagDetails,
            )
          : GelbooruPostDetailsPage(
              posts: payload.posts.map((e) => e as GelbooruPost).toList(),
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => config.hasLoginDetails()
          ? GelbooruFavoritesPage(uid: config.login!)
          : const Scaffold(
              body: Center(
                child: Text(
                    'You need to provide login details to use this feature.'),
              ),
            );

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruArtistPage(
            artistName: artistName,
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => GelbooruCommentPage(
            postId: postId,
          );

  @override
  DownloadFilenameGenerator get downloadFilenameBuilder =>
      DownloadFileNameBuilder(
        defaultFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat:
            kGelbooruCustomDownloadFileNameFormat,
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
}

class GelbooruSearchPage extends ConsumerWidget {
  const GelbooruSearchPage({
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
          ref.watch(gelbooruPostRepoProvider(config)).getPosts(tags, page),
    );
  }
}

class GelbooruCommentPage extends ConsumerWidget {
  const GelbooruCommentPage({
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
          ref.watch(gelbooruCommentRepoProvider(config)).getComments(postId),
    );
  }
}

class GelbooruFavoritesPage extends ConsumerWidget {
  const GelbooruFavoritesPage({
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
          ref.read(gelbooruPostRepoProvider(config)).getPosts([query], page),
    );
  }
}
