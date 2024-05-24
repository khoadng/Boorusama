// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/types/types.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/feats/utils.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/posts/post_details_page_mixin.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';
import 'artists/gelbooru_artist_page.dart';
import 'comments/gelbooru_comment_page.dart';
import 'configs/create_gelbooru_config_page.dart';
import 'home/gelbooru_home_page.dart';
import 'posts/gelbooru_post_details_desktop_page.dart';
import 'posts/gelbooru_post_details_page.dart';

export 'posts/posts.dart';

const kGelbooruCustomDownloadFileNameFormat =
    '{id}_{md5:maxlength=8}.{extension}';

String getGelbooruProfileUrl(String url) => url.endsWith('/')
    ? '${url}index.php?page=account&s=options'
    : '$url/index.php?page=account&s=options';

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

final gelbooruNoteRepoProvider =
    Provider.family<NoteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(gelbooruClientProvider(config));

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotesFromPostId(
          postId: postId,
        )
        .then((value) => value.map(gelbooruNoteToNote).toList()),
  );
});

Note gelbooruNoteToNote(NoteDto note) {
  return Note(
    coordinate: NoteCoordinate(
      x: note.x?.toDouble() ?? 0,
      y: note.y?.toDouble() ?? 0,
      height: note.height?.toDouble() ?? 0,
      width: note.width?.toDouble() ?? 0,
    ),
    content: note.body ?? '',
  );
}

class GelbooruBuilder
    with
        FavoriteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        DefaultThumbnailUrlMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultTagColorMixin
    implements BooruBuilder {
  GelbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.noteRepo,
    required this.client,
  });

  final PostRepository<GelbooruPost> postRepo;
  final AutocompleteRepository autocompleteRepo;
  final NoteRepository noteRepo;
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
            isNewConfig: true,
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
  NoteFetcher? get noteFetcher => (postId) => noteRepo.getNotes(postId);

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  PostCountFetcher? get postCountFetcher =>
      (config, tags, granularRatingQueryBuilder) {
        return client
            .getPosts(
              tags: getTags(
                config,
                tags,
                granularRatingQueries: (tags) =>
                    granularRatingQueryBuilder?.call(tags, config),
              ),
            )
            .then((value) => value.count);
      };

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => PostDetailsLayoutSwitcher(
            initialIndex: payload.initialIndex,
            scrollController: payload.scrollController,
            desktop: (controller) => GelbooruPostDetailsDesktopPage(
              initialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as GelbooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
            mobile: (controller) => GelbooruPostDetailsPage(
              initialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as GelbooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
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
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => GelbooruArtistPage(
            artistName: characterName,
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => GelbooruCommentPage(
            postId: postId,
          );

  @override
  GranularRatingQueryBuilder? get granularRatingQueryBuilder =>
      (currentQuery, config) => switch (config.ratingFilter) {
            BooruConfigRatingFilter.none => currentQuery,
            BooruConfigRatingFilter.hideNSFW => [
                ...currentQuery,
                'rating:general',
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
                      ...ratings.map((e) => '-rating:${e.toFullString()}'),
                    ],
                  ),
          };

  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
        Rating.general,
      };

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
      fetcher: (page, tags) =>
          ref.watch(gelbooruPostRepoProvider(config)).getPosts(tags, page),
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
