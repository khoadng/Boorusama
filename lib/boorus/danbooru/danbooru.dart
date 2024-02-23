// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/comment_page.dart';
import 'package:boorusama/boorus/danbooru/pages/danbooru_character_page.dart';
import 'package:boorusama/boorus/danbooru/pages/danbooru_post_statistics_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/pages/post_statistics_page.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';
import 'pages/create_danbooru_config_page.dart';
import 'pages/danbooru_artist_page.dart';
import 'pages/danbooru_home_page.dart';
import 'pages/danbooru_post_details_desktop_page.dart';
import 'pages/danbooru_post_details_page.dart';
import 'pages/danbooru_search_page.dart';
import 'pages/favorites_page.dart';

const kDanbooruSafeUrl = 'https://safebooru.donmai.us/';

const kDanbooruPostSamples = [
  {
    'id': '123456',
    'artist': 'artist_x_(abc) artist_2',
    'character':
        'lumine_(genshin_impact) lumine_(sweets_paradise)_(genshin_impact) aether_(genshin_impact)',
    'copyright': 'genshin_impact fate/grand_order',
    'general': '1girl solo',
    'meta': 'highres translated',
    'tags':
        '1girl solo genshin_impact lumine_(genshin_impact) lumine_(sweets_paradise)_(genshin_impact) aether_(genshin_impact) highres translated',
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
    'character': 'hatsune_miku',
    'copyright': 'vocaloid',
    'general': '1girl solo',
    'meta': 'highres translated',
    'tags': '1girl solo hatsune_miku vocaloid highres translated',
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

class DanbooruBuilder
    with
        DefaultTagColorMixin,
        NewGranularRatingOptionsBuilderMixin,
        NewGranularRatingQueryBuilderMixin
    implements BooruBuilder {
  const DanbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.favoriteRepo,
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
      (postId, ref) => ref.danbooruFavorites.add(postId).then((_) => true);

  @override
  FavoriteRemover? get favoriteRemover =>
      (postId, ref) => ref.danbooruFavorites.remove(postId).then((_) => true);

  @override
  PostCountFetcher? get postCountFetcher =>
      (config, tags, _) => postCountRepo.count(tags);

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
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => DanbooruCharacterPage(
          characterName: characterName, backgroundImageUrl: '');

  @override
  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder =>
      (settings, post) => castOrNull<DanbooruPost>(post).toOption().fold(
            () => post.thumbnailImageUrl,
            (post) => post.thumbnailFromSettings(settings),
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => CommentPage(
            postId: postId,
            useAppBar: useAppBar,
          );

  @override
  NoteFetcher? get noteFetcher => (postId) => noteRepo.getNotes(postId);

  @override
  PostGestureHandlerBuilder get postGestureHandlerBuilder =>
      (ref, action, post, downloader) => handleDanbooruGestureAction(
            action,
            onDownload: () => downloader(post),
            onShare: () => ref.sharePost(
              post,
              context: ref.context,
              state: ref.read(postShareProvider(post)),
            ),
            onToggleBookmark: () => ref.toggleBookmark(post),
            onToggleFavorite: () => ref.danbooruToggleFavorite(post.id),
            onUpvote: () => ref.danbooruUpvote(post.id),
            onDownvote: () => ref.danbooruDownvote(post.id),
            onEdit: () => castOrNull<DanbooruPost>(post).toOption().fold(
                  () => false,
                  (post) => ref.danbooruEdit(post),
                ),
            onViewTags: () => castOrNull<DanbooruPost>(post).toOption().fold(
                  () => goToShowTaglistPage(
                    ref,
                    post.extractTags(),
                  ),
                  (post) => goToDanbooruShowTaglistPage(
                    ref,
                    post.extractTags(),
                  ),
                ),
            onViewOriginal: () => goToOriginalImagePage(ref.context, post),
            onOpenSource: () => post.source.whenWeb(
              (source) => launchExternalUrlString(source.url),
              () => false,
            ),
          );

  @override
  DownloadFilenameGenerator get downloadFilenameBuilder =>
      DownloadFileNameBuilder<DanbooruPost>(
        defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat:
            kBoorusamaBulkDownloadCustomFileNameFormat,
        sampleData: kDanbooruPostSamples,
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
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder => (settings,
          rawPost, config) =>
      castOrNull<DanbooruPost>(rawPost).toOption().fold(
            () => rawPost.sampleImageUrl,
            (post) => post.isGif
                ? post.sampleImageUrl
                : config.imageDetaisQuality.toOption().fold(
                    () => switch (settings.imageQuality) {
                          ImageQuality.highest ||
                          ImageQuality.original =>
                            post.sampleImageUrl,
                          _ => post.url720x720,
                        },
                    (quality) => switch (mapStringToPostQualityType(quality)) {
                          PostQualityType.v180x180 => post.url180x180,
                          PostQualityType.v360x360 => post.url360x360,
                          PostQualityType.v720x720 => post.url720x720,
                          PostQualityType.sample => post.isVideo
                              ? post.url720x720
                              : post.sampleImageUrl,
                          PostQualityType.original => post.isVideo
                              ? post.url720x720
                              : post.originalImageUrl,
                          null => post.url720x720,
                        }),
          );

  @override
  PostStatisticsPageBuilder get postStatisticsPageBuilder => (context, posts) {
        try {
          return DanbooruPostStatisticsPage(
            posts: posts.map((e) => e as DanbooruPost).toList(),
          );
        } catch (e) {
          return PostStatisticsPage(
            totalPosts: () => posts.length,
            generalStats: () => posts.getStats(),
          );
        }
      };

  @override
  GranularRatingFilterer? get granularRatingFilterer =>
      (post, config) => switch (config.ratingFilter) {
            BooruConfigRatingFilter.none => false,
            BooruConfigRatingFilter.hideNSFW => post.rating != Rating.general,
            BooruConfigRatingFilter.hideExplicit => post.rating.isNSFW(),
            BooruConfigRatingFilter.custom =>
              config.granularRatingFiltersWithoutUnknown.toOption().fold(
                    () => false,
                    (ratings) => !ratings.contains(post.rating),
                  ),
          };
}

bool handleDanbooruGestureAction(
  String? action, {
  void Function()? onDownload,
  void Function()? onShare,
  void Function()? onToggleBookmark,
  void Function()? onViewTags,
  void Function()? onViewOriginal,
  void Function()? onOpenSource,
  void Function()? onToggleFavorite,
  void Function()? onUpvote,
  void Function()? onDownvote,
  void Function()? onEdit,
}) {
  switch (action) {
    case kToggleFavoriteAction:
      onToggleFavorite?.call();
      break;
    case kUpvoteAction:
      onUpvote?.call();
      break;
    case kDownvoteAction:
      onDownvote?.call();
      break;
    case kEditAction:
      onEdit?.call();
      break;
    default:
      return handleDefaultGestureAction(
        action,
        onDownload: onDownload,
        onShare: onShare,
        onToggleBookmark: onToggleBookmark,
        onViewTags: onViewTags,
        onViewOriginal: onViewOriginal,
        onOpenSource: onOpenSource,
      );
  }

  return true;
}

extension DanbooruX on WidgetRef {
  void danbooruToggleFavorite(int postId) {
    _guardLogin(() {
      final isFaved = read(danbooruFavoriteProvider(postId));
      if (isFaved) {
        danbooruFavorites.remove(postId);
      } else {
        danbooruFavorites.add(postId);
      }
    });
  }

  void danbooruUpvote(int postId) {
    _guardLogin(() {
      read(danbooruPostVotesProvider(readConfig).notifier).upvote(postId);
    });
  }

  void danbooruDownvote(int postId) {
    _guardLogin(() {
      read(danbooruPostVotesProvider(readConfig).notifier).downvote(postId);
    });
  }

  void _guardLogin(void Function() action) {
    if (!readConfig.hasLoginDetails()) {
      showSimpleSnackBar(
        context: this.context,
        content: const Text(
          'post.detail.login_required_notice',
        ).tr(),
        duration: const Duration(seconds: 1),
      );

      return;
    }

    action();
  }

  void danbooruEdit(DanbooruPost post) {
    goToTagEditPage(
      this.context,
      post: post,
    );
  }
}
