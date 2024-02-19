// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_category.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/comments/comment.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/scaffolds/comment_page_scaffold.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart';
import 'pages/create_e621_config_page.dart';
import 'pages/e621_artist_page.dart';
import 'pages/e621_favorites_page.dart';
import 'pages/e621_home_page.dart';
import 'pages/e621_post_details_desktop_page.dart';
import 'pages/e621_post_details_page.dart';
import 'pages/e621_search_page.dart';

final e621ClientProvider =
    Provider.family<E621Client, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

  return E621Client(
    baseUrl: booruConfig.url,
    dio: dio,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
  );
});

final e621AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(e621ClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    persistentStaleDuration: const Duration(days: 1),
    autocomplete: (query) async {
      final dtos = await client.getAutocomplete(query: query);

      return dtos
          .map((e) => AutocompleteData(
                type: AutocompleteData.tag,
                label: e.name?.replaceAll('_', ' ') ?? '',
                value: e.name ?? '',
                category: intToE621TagCategory(e.category).name,
                postCount: e.postCount,
                antecedent: e.antecedentName,
              ))
          .toList();
    },
  );
});

const kE621PostSamples = [
  {
    'id': '123456',
    'artist': 'artist_x_(abc) artist_2',
    'character': 'sonic_the_hedgehog classic_sonic',
    'copyright': 'sonic_the_hedgehog_(comics) sonic_the_hedgehog_(series)',
    'general': 'male solo',
    'meta': 'highres translated',
    'species': 'mammal hedgehog',
    'tags':
        'male solo sonic_the_hedgehog classic_sonic sonic_the_hedgehog_(comics) sonic_the_hedgehog_(series) highres translated mammal hedgehog',
    'extension': 'jpg',
    'md5': '9cf364e77f46183e2ebd75de757488e2',
    'width': '2232',
    'height': '1000',
    'aspect_ratio': '0.44776119402985076',
    'mpixels': '2.232356356345635',
    'source': 'https://example.com/filename.jpg',
    'rating': 'general',
    'index': '0',
  },
  {
    'id': '654321',
    'artist': 'artist_3',
    'character': 'classic_sonic',
    'copyright': 'sega',
    'general': 'male solo',
    'meta': 'highres translated',
    'species': 'mammal hedgehog',
    'tags': 'male solo classic_sonic sega highres translated mammal hedgehog',
    'extension': 'png',
    'md5': '2ebd75de757488e29cf364e77f46183e',
    'width': '1334',
    'height': '2232',
    'aspect_ratio': '0.598744769874477',
    'mpixels': '2.976527856856785678',
    'source': 'https://example.com/example_filename.jpg',
    'rating': 'general',
    'index': '1',
  }
];

class E621Builder
    with
        PostCountNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        LegacyGranularRatingQueryBuilderMixin,
        DefaultThumbnailUrlMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostImageDetailsUrlMixin
    implements BooruBuilder {
  E621Builder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.noteRepo,
  });

  final PostRepository<E621Post> postRepo;
  final AutocompleteRepository autocompleteRepo;
  final NoteRepository noteRepo;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateE621ConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat:
                  kBoorusamaCustomDownloadFileNameFormat,
            ),
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => E621HomePage(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateE621ConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(tags, page);

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  FavoriteAdder? get favoriteAdder => (postId, ref) => ref
      .read(e621FavoritesProvider(ref.readConfig).notifier)
      .add(postId)
      .then((value) => true);

  @override
  FavoriteRemover? get favoriteRemover => (postId, ref) => ref
      .read(e621FavoritesProvider(ref.readConfig).notifier)
      .remove(postId)
      .then((value) => true);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => E621SearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => payload.isDesktop
          ? E621PostDetailsDesktopPage(
              initialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as E621Post).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            )
          : E621PostDetailsPage(
              intitialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as E621Post).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => config.hasLoginDetails()
          ? E621FavoritesPage(username: config.login!)
          : const Scaffold(
              body: Center(
                child: Text(
                    'You need to provide login details to use this feature.'),
              ),
            );

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => E621ArtistPage(artistName: artistName);

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => E621CommentPage(postId: postId);

  @override
  TagColorBuilder get tagColorBuilder =>
      (context, tagType) => switch (tagType) {
            'general' => const Color(0xffb4c7d8),
            'artist' => const Color(0xfff2ad04),
            'copyright' => const Color(0xffd60ad8),
            'character' => const Color(0xff05a903),
            'species' => const Color(0xffed5d1f),
            'invalid' => const Color(0xfffe3c3d),
            'meta' => const Color(0xfffefffe),
            'lore' => const Color(0xff218923),
            _ => const Color(0xffb4c7d8),
          };

  @override
  NoteFetcher? get noteFetcher => (postId) => noteRepo.getNotes(postId);

  @override
  DownloadFilenameGenerator get downloadFilenameBuilder =>
      DownloadFileNameBuilder<E621Post>(
        defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat:
            kBoorusamaBulkDownloadCustomFileNameFormat,
        sampleData: kE621PostSamples,
        tokenHandlers: {
          'id': (post, config) => post.id.toString(),
          'artist': (post, config) => post.artistTags.join(' '),
          'character': (post, config) => post.characterTags.join(' '),
          'copyright': (post, config) => post.copyrightTags.join(' '),
          'general': (post, config) => post.generalTags.join(' '),
          'meta': (post, config) => post.metaTags.join(' '),
          'species': (post, config) => post.speciesTags.join(' '),
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

class E621CommentPage extends ConsumerWidget {
  const E621CommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(e621ClientProvider(ref.watchConfig));

    return CommentPageScaffold(
      postId: postId,
      fetcher: (id) => client.getComments(postId: postId, page: 1).then(
            (value) => value
                .map((e) => SimpleComment(
                      id: e.id ?? 0,
                      body: e.body ?? '',
                      createdAt: e.createdAt ?? DateTime(1),
                      updatedAt: e.updatedAt ?? DateTime(1),
                      creatorName: e.creatorName ?? '',
                      creatorId: e.creatorId ?? 0,
                    ))
                .toList(),
          ),
    );
  }
}
