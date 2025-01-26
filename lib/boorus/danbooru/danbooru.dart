// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/blacklists/blacklist.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/downloads/downloader.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/foundation/url_launcher.dart';
import '../../core/home/custom_home.dart';
import '../../core/home/user_custom_home_builder.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/listing/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/routes.dart';
import '../../core/posts/post/tags.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/shares/providers.dart';
import '../../core/posts/shares/widgets.dart';
import '../../core/posts/sources/source.dart';
import '../../core/posts/statistics/stats.dart';
import '../../core/posts/statistics/widgets.dart';
import '../../core/settings/settings.dart';
import '../../core/tags/metatag/providers.dart';
import '../../core/tags/tag/routes.dart';
import '../../core/tags/tag/tag.dart';
import 'artists/artist/widgets.dart';
import 'artists/search/src/artist_search_page.dart';
import 'autocompletes/providers.dart';
import 'autocompletes/widgets.dart';
import 'blacklist/providers.dart';
import 'comments/listing/widgets.dart';
import 'configs/widgets.dart';
import 'forums/topics/src/forum_page.dart';
import 'home/widgets.dart';
import 'notes/providers.dart';
import 'posts/count/providers.dart';
import 'posts/details/widgets.dart';
import 'posts/explores/src/pages/danbooru_explore_page.dart';
import 'posts/favgroups/listing/widgets.dart';
import 'posts/favorites/providers.dart';
import 'posts/favorites/widgets.dart';
import 'posts/listing/providers.dart';
import 'posts/listing/widgets.dart';
import 'posts/pools/listing/widgets.dart';
import 'posts/post/post.dart';
import 'posts/post/providers.dart';
import 'posts/search/widgets.dart';
import 'posts/statistics/widgets.dart';
import 'posts/votes/providers.dart';
import 'saved_searches/feed/widgets.dart';
import 'tags/details/widgets.dart';
import 'tags/tag/providers.dart';
import 'tags/tag/routes.dart';

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
  HomePageBuilder get homePageBuilder => (context) => const DanbooruHomePage();

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
          initialThumbnailUrl: payload.initialThumbnailUrl,
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
                    ref.context,
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
            onToggleFavorite: () => ref.toggleFavorite(post.id),
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
  HomeViewBuilder get homeViewBuilder => (context) {
        return const UserCustomHomeBuilder(
          defaultView: LatestView(),
        );
      };

  @override
  MetatagExtractorBuilder get metatagExtractorBuilder =>
      (tagInfo) => DefaultMetatagExtractor(
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
  final Map<CustomHomeViewKey, CustomHomeDataBuilder> customHomeViewBuilders = {
    ...kDefaultAltHomeView,
    const CustomHomeViewKey('explore'): CustomHomeDataBuilder(
      displayName: 'explore.explore',
      builder: (context, _) => const DanbooruExplorePage(),
    ),
    const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
      displayName: 'profile.favorites',
      builder: (context, _) => const DanbooruFavoritesPage(),
    ),
    const CustomHomeViewKey('artists'): CustomHomeDataBuilder(
      displayName: 'Artists',
      builder: (context, _) => const DanbooruArtistSearchPage(),
    ),
    const CustomHomeViewKey('forum'): CustomHomeDataBuilder(
      displayName: 'forum.forum',
      builder: (context, _) => const DanbooruForumPage(),
    ),
    const CustomHomeViewKey('favgroup'): CustomHomeDataBuilder(
      displayName: 'favorite_groups.favorite_groups',
      builder: (context, _) => const FavoriteGroupsPage(),
    ),
    const CustomHomeViewKey('saved_searches'): CustomHomeDataBuilder(
      displayName: 'saved_search.saved_search',
      builder: (context, _) => const SavedSearchFeedPage(),
    ),
    const CustomHomeViewKey('pools'): CustomHomeDataBuilder(
      displayName: 'Pools',
      builder: (context, _) => const DanbooruPoolPage(),
    ),
  };

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    previewAllowedParts: {
      DetailsPart.tags,
    },
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

  @override
  TagSuggestionItemBuilder get tagSuggestionItemBuilder =>
      (config, tag, dense, currentQuery, onItemTap) =>
          DanbooruTagSuggestionItem(
            config: config,
            tag: tag,
            dense: dense,
            currentQuery: currentQuery,
            onItemTap: onItemTap,
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
    case kUpvoteAction:
      onUpvote?.call();
    case kDownvoteAction:
      onDownvote?.call();
    case kEditAction:
      onEdit?.call();
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

class DanbooruRepository implements BooruRepository {
  const DanbooruRepository({
    required this.ref,
    required this.booru,
  });

  final Booru booru;

  @override
  final Ref ref;

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return ref.read(danbooruPostCountRepoProvider(config));
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(danbooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(danbooruAutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(danbooruNoteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(danbooruTagRepoProvider(config));
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return const UrlInsidePostExtractor();
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return DanbooruFavoriteRepository(ref, config);
  }

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return DanbooruBlacklistTagRepository(
      ref,
      config,
      booru: booru,
    );
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => DanbooruClient(
          baseUrl: config.url,
          dio: dio,
          login: config.login,
          apiKey: config.apiKey,
        ).getPosts().then((value) => true);
  }
}
