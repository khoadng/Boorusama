// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/functional.dart';
import 'artists/danbooru_artist_page.dart';
import 'comments/comments.dart';
import 'configs/create_danbooru_config_page.dart';
import 'favorites/favorites.dart';
import 'home/danbooru_home_page.dart';
import 'post_votes/post_votes.dart';
import 'posts/posts.dart';
import 'reports/reports.dart';
import 'search/search.dart';
import 'tags/tags.dart';

const kDanbooruSafeUrl = 'https://safebooru.donmai.us/';

String getDanbooruProfileUrl(String url) =>
    url.endsWith('/') ? '${url}profile' : '$url/profile';

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
    'search': 'genshin_impact solo',
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
    'search': '1girl solo',
  }
];

class DanbooruBuilder
    with
        DefaultTagColorMixin,
        NewGranularRatingOptionsBuilderMixin,
        NewGranularRatingQueryBuilderMixin
    implements BooruBuilder {
  DanbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.favoriteRepo,
    required this.postCountRepo,
    required this.noteRepo,
    required this.tagInfo,
  });

  final PostRepository<DanbooruPost> postRepo;
  final AutocompleteRepository autocompleteRepo;
  final FavoritePostRepository favoriteRepo;
  final PostCountRepository postCountRepo;
  final NoteRepository noteRepo;
  final TagInfo tagInfo;

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
            isNewConfig: true,
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
      (config, tags, granularRatingQueryBuilder) => postCountRepo.count({
            ...tags,
            if (granularRatingQueryBuilder != null)
              ...granularRatingQueryBuilder(tags, config),
          }.toList());

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => DanbooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => PostDetailsLayoutSwitcher(
            initialIndex: payload.initialIndex,
            scrollController: payload.scrollController,
            desktop: (controller) => DanbooruPostDetailsDesktopPage(
              initialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as DanbooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
            mobile: (controller) => DanbooruPostDetailsPage(
              intitialIndex: controller.currentPage.value,
              posts: payload.posts.map((e) => e as DanbooruPost).toList(),
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
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
      (imageQuality, post) => castOrNull<DanbooruPost>(post).toOption().fold(
            () => post.thumbnailImageUrl,
            (post) => post.thumbnailFromImageQuality(imageQuality),
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
      (ref, action, post) => handleDanbooruGestureAction(
            action,
            onDownload: () => ref.download(post),
            onShare: () => ref.sharePost(
              post,
              context: ref.context,
              state: ref.read(postShareProvider(post)),
            ),
            onToggleBookmark: () => ref.toggleBookmark(post),
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
            onToggleFavorite: () => ref.danbooruToggleFavorite(post.id),
            onUpvote: () => ref.danbooruUpvote(post.id),
            onDownvote: () => ref.danbooruDownvote(post.id),
            onEdit: () => castOrNull<DanbooruPost>(post).toOption().fold(
                  () => false,
                  (post) => ref.danbooruEdit(post),
                ),
          );

  @override
  final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder<DanbooruPost>(
    defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat:
        kBoorusamaBulkDownloadCustomFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'artist': (post, config) => post.artistTags.join(' '),
      'character': (post, config) => post.characterTags.join(' '),
      'copyright': (post, config) => post.copyrightTags.join(' '),
      'general': (post, config) => post.generalTags.join(' '),
      'meta': (post, config) => post.metaTags.join(' '),
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'mpixels': (post, config) => post.mpixels.toString(),
      'aspect_ratio': (post, config) => post.aspectRatio.toString(),
      'source': (post, config) => config.downloadUrl,
    },
  );

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder =>
      (imageQuality, rawPost, config) =>
          castOrNull<DanbooruPost>(rawPost).toOption().fold(
                () => rawPost.sampleImageUrl,
                (post) => post.isGif
                    ? post.sampleImageUrl
                    : config.imageDetaisQuality.toOption().fold(
                          () => switch (imageQuality) {
                            ImageQuality.highest ||
                            ImageQuality.original =>
                              post.sampleImageUrl,
                            _ => post.url720x720,
                          },
                          (quality) =>
                              switch (mapStringToPostQualityType(quality)) {
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
                          },
                        ),
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
                    (ratings) => ratings.contains(post.rating),
                  ),
          };

  @override
  HomeViewBuilder get homeViewBuilder => (context, config, controller) {
        return LatestView(
          searchBar: HomeSearchBar(
            onMenuTap: controller.openMenu,
            onTap: () => goToSearchPage(context),
          ),
        );
      };

  @override
  late final MetatagExtractor metatagExtractor = MetatagExtractor(
    metatags: tagInfo.metatags,
  );
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
    _guardLogin(() async {
      final isFaved = read(danbooruFavoriteProvider(postId));
      if (isFaved) {
        await danbooruFavorites.remove(postId);
        if (context.mounted) {
          _showSuccessSnackBar(
            context,
            'Removed from favorites',
          );
        }
      } else {
        await danbooruFavorites.add(postId);
        if (context.mounted) {
          _showSuccessSnackBar(
            context,
            'Added to favorites',
          );
        }
      }
    });
  }

  void danbooruRemoveVote(int postId) {
    _guardLogin(() async {
      await read(danbooruPostVotesProvider(readConfig).notifier)
          .removeVote(postId);

      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          'Vote removed',
        );
      }
    });
  }

  void danbooruUpvote(int postId) {
    _guardLogin(() async {
      await read(danbooruPostVotesProvider(readConfig).notifier).upvote(postId);

      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          'Upvoted',
        );
      }
    });
  }

  void danbooruDownvote(int postId) {
    _guardLogin(() async {
      await read(danbooruPostVotesProvider(readConfig).notifier)
          .downvote(postId);

      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          'Downvoted',
        );
      }
    });
  }

  void danbooruEdit(DanbooruPost post) {
    _guardLogin(() {
      goToTagEditPage(
        context,
        post: post,
      );
    });
  }

  void _showSuccessSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    showSuccessToast(
      context,
      message,
      backgroundColor: backgroundColor,
      duration: AppDurations.shortToast,
    );
  }

  void _guardLogin(void Function() action) {
    if (!readConfig.hasLoginDetails()) {
      showSimpleSnackBar(
        context: context,
        content: const Text(
          'post.detail.login_required_notice',
        ).tr(),
        duration: AppDurations.shortToast,
      );

      return;
    }

    action();
  }
}
