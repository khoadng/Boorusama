// Flutter imports:
import 'package:boorusama/core/feats/downloads/download_file_name_generator.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/comment_page.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart'
    hide DownloadFileNameBuilder;
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'pages/create_danbooru_config_page.dart';
import 'pages/danbooru_artist_page.dart';
import 'pages/danbooru_home_page.dart';
import 'pages/danbooru_post_details_desktop_page.dart';
import 'pages/danbooru_post_details_page.dart';
import 'pages/danbooru_search_page.dart';
import 'pages/favorites_page.dart';

const kDanbooruSafeUrl = 'https://safebooru.donmai.us/';

const kDanbooruPostSample = <String, String>{
  'id': '123456',
  'artist': 'artist_x_(abc) artist_2',
  'character':
      'lumine_(genshin_impact) lumine_(sweets_paradise)_(genshin_impact) aether_(genshin_impact)',
  'copyright': 'genshin_impact fate/grand_order',
  'general': '1girl solo',
  'meta': 'highres translated',
  'tags':
      'genshin_impact lumine_(genshin_impact) lumine_(sweets_paradise)_(genshin_impact) aether_(genshin_impact) 1girl solo highres translated',
  'extension': 'jpg',
  'md5': '9cf364e77f46183e2ebd75de757488e2',
  'source': 'https://example.com/filename.jpg',
  'rating': 'general',
  'index': '0',
};

class DanbooruBuilder with DefaultTagColorMixin implements BooruBuilder {
  const DanbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.favoriteRepo,
    required this.favoriteChecker,
    required this.postCountRepo,
    required this.noteRepo,
  });

  final PostRepository<DanbooruPost> postRepo;
  final AutocompleteRepository autocompleteRepo;
  final FavoritePostRepository favoriteRepo;
  final PostCountRepository postCountRepo;
  final NoteRepository noteRepo;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateDanbooruConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat:
                  kBoorusamaCustomDownloadFileNameFormat,
            ),
            backgroundColor: backgroundColor,
            defaultFilenameFormat: kBoorusamaCustomDownloadFileNameFormat,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => DanbooruHomePage(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateDanbooruConfigPage(
            config: config,
            backgroundColor: backgroundColor,
            defaultFilenameFormat: kBoorusamaCustomDownloadFileNameFormat,
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
  FavoriteAdder? get favoriteAdder =>
      (postId) => favoriteRepo.addToFavorites(postId);

  @override
  FavoriteRemover? get favoriteRemover =>
      (postId) => favoriteRepo.removeFromFavorites(postId);

  @override
  final FavoriteChecker? favoriteChecker;

  @override
  PostCountFetcher? get postCountFetcher => (tags) => postCountRepo.count(tags);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => CustomContextMenuOverlay(
            child: DanbooruSearchPage(initialQuery: initialQuery),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => payload.isDesktop
          ? DanbooruPostDetailsDesktopPage(
              initialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as DanbooruPost).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            )
          : DanbooruPostDetailsPage(
              intitialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as DanbooruPost).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => config.login != null
          ? DanbooruFavoritesPage(username: config.login!)
          : Scaffold(
              appBar: AppBar(
                title: const Text('Favorites'),
              ),
              body: const Center(
                child: Text('You must be logged in to view your favorites'),
              ),
            );

  @override
  ArtistPageBuilder? get artistPageBuilder => (context, artistName) =>
      DanbooruArtistPage(artistName: artistName, backgroundImageUrl: '');

  @override
  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder => (settings, post) =>
      (post as DanbooruPost).thumbnailFromSettings(settings);

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => CommentPage(
            postId: postId,
            useAppBar: useAppBar,
          );

  @override
  NoteFetcher? get noteFetcher => (postId) => noteRepo.getNotes(postId);

  @override
  DownloadFilenameGenerator get downloadFilenameBuilder =>
      DownloadFileNameBuilder<DanbooruPost>(
        sampleData: kDanbooruPostSample,
        tokenHandlers: {
          'id': (post, config) => post.id.toString(),
          'artist': (post, config) => post.artistTags.join(' '),
          'character': (post, config) => post.characterTags.join(' '),
          'copyright': (post, config) => post.copyrightTags.join(' '),
          'general': (post, config) => post.generalTags.join(' '),
          'meta': (post, config) => post.metaTags.join(' '),
          'tags': (post, config) => post.tags.join(' '),
          'extension': (post, config) =>
              extension(config.downloadUrl).substring(1),
          'md5': (post, config) => post.md5,
          'source': (post, config) => config.downloadUrl,
          'rating': (post, config) => post.rating.name,
          'index': (post, config) => config.index?.toString(),
        },
      );
}
