// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/create.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/details.dart';
import 'package:boorusama/core/posts/listing.dart';
import 'package:boorusama/core/posts/shares.dart';
import 'package:boorusama/core/posts/sources.dart';
import 'package:boorusama/core/posts/statistics.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
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
    with DefaultTagColorMixin, NewGranularRatingOptionsBuilderMixin
    implements BooruBuilder {
  DanbooruBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat:
                  kBoorusamaCustomDownloadFileNameFormat,
            ),
            child: CreateDanbooruConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  HomePageBuilder get homePageBuilder => (context) => DanbooruHomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateDanbooruConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => DanbooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as DanbooruPost).toList();

        return PostDetailsScope<DanbooruPost>(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DanbooruPostDetailsPage(),
        );
      };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const DanbooruFavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => DanbooruArtistPage(artistName: artistName);

  @override
  CharacterPageBuilder? get characterPageBuilder => (context, characterName) =>
      DanbooruCharacterPage(characterName: characterName);

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
      (post, config) => switch (config.filter.ratingFilter) {
            BooruConfigRatingFilter.none => false,
            BooruConfigRatingFilter.hideNSFW => post.rating != Rating.general,
            BooruConfigRatingFilter.hideExplicit => post.rating.isNSFW(),
            BooruConfigRatingFilter.custom =>
              config.filter.granularRatingFiltersWithoutUnknown.toOption().fold(
                    () => false,
                    (ratings) => ratings.contains(post.rating),
                  ),
          };

  @override
  HomeViewBuilder get homeViewBuilder => (context, controller) {
        return LatestView(
          controller: controller,
        );
      };

  @override
  MetatagExtractorBuilder get metatagExtractorBuilder =>
      (tagInfo) => MetatagExtractor(
            metatags: tagInfo.metatags,
          );

  @override
  QuickFavoriteButtonBuilder get quickFavoriteButtonBuilder =>
      (context, post) => castOrNull<DanbooruPost>(post).toOption().fold(
            () => const SizedBox.shrink(),
            (post) => DanbooruQuickFavoriteButton(
              post: post,
            ),
          );

  @override
  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder =>
      (context, controller) {
        final isDanController =
            controller is MultiSelectController<DanbooruPost>;

        return isDanController
            ? DanbooruMultiSelectionActions(controller: controller)
            : DefaultMultiSelectionActions(controller: controller);
      };

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.info: (context) => const DanbooruInformationSection(),
      DetailsPart.toolbar: (context) =>
          const DanbooruInheritedPostActionToolbar(),
    },
    full: {
      DetailsPart.pool: (context) => const DanbooruPoolTiles(),
      DetailsPart.info: (context) => const DanbooruInformationSection(),
      DetailsPart.toolbar: (context) =>
          const DanbooruInheritedPostActionToolbar(),
      DetailsPart.artistInfo: (context) => const DanbooruArtistInfoSection(),
      DetailsPart.stats: (context) => const DanbooruStatsSection(),
      DetailsPart.tags: (context) => const DanbooruTagsSection(),
      DetailsPart.fileDetails: (context) => const DanbooruFileDetailsSection(),
      DetailsPart.artistPosts: (context) => const DanbooruArtistPostsSection(),
      DetailsPart.relatedPosts: (context) =>
          const DanbooruRelatedPostsSection2(),
      DetailsPart.characterList: (context) =>
          const DanbooruCharacterListSection(),
    },
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
      await read(danbooruPostVotesProvider(readConfigAuth).notifier)
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
      await read(danbooruPostVotesProvider(readConfigAuth).notifier)
          .upvote(postId);

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
      await read(danbooruPostVotesProvider(readConfigAuth).notifier)
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
    guardLogin(this, action);
  }
}

void guardLogin(WidgetRef ref, void Function() action) {
  if (!ref.readConfigAuth.hasLoginDetails()) {
    showSimpleSnackBar(
      context: ref.context,
      content: const Text(
        'post.detail.login_required_notice',
      ).tr(),
      duration: AppDurations.shortToast,
    );

    return;
  }

  action();
}
