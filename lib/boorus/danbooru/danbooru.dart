// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/blacklists/blacklist.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/gesture/gesture.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/downloads/downloader.dart';
import '../../core/downloads/filename.dart';
import '../../core/foundation/url_launcher.dart';
import '../../core/home/custom_home.dart';
import '../../core/home/user_custom_home_builder.dart';
import '../../core/http/http.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/listing/list.dart';
import '../../core/posts/listing/providers.dart';
import '../../core/posts/listing/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/routes.dart';
import '../../core/posts/post/tags.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/shares/providers.dart';
import '../../core/posts/shares/widgets.dart';
import '../../core/posts/sources/source.dart';
import '../../core/posts/statistics/stats.dart';
import '../../core/posts/statistics/widgets.dart';
import '../../core/search/queries/query.dart';
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
import 'syntax/src/providers/providers.dart';
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

class DanbooruBuilder implements BooruBuilder {
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
      (context, params) => DanbooruSearchPage(
            params: params,
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as DanbooruPost).toList();

        return PostDetailsScope<DanbooruPost>(
          initialIndex: payload.initialIndex,
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: posts,
          scrollController: payload.scrollController,
          dislclaimer: payload.dislclaimer,
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
                          (quality) => switch (PostQualityType.parse(quality)) {
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
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
        Rating.general,
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
      (context, controller, postController) {
        final isDanController =
            postController is PostGridController<DanbooruPost>;

        return isDanController
            ? DanbooruMultiSelectionActions(
                controller: controller,
                postController: postController,
              )
            : DefaultMultiSelectionActions(
                controller: controller,
                postController: postController,
              );
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
      DetailsPart.info: (context) => const DanbooruInformationSection(),
      DetailsPart.toolbar: (context) =>
          const DanbooruInheritedPostActionToolbar(),
      DetailsPart.artistInfo: (context) => const DanbooruArtistInfoSection(),
      DetailsPart.stats: (context) => const DanbooruStatsSection(),
      DetailsPart.tags: (context) => const DanbooruTagsSection(),
      DetailsPart.fileDetails: (context) => const DanbooruFileDetailsSection(),
      DetailsPart.artistPosts: (context) => const DanbooruArtistPostsSection(),
      DetailsPart.pool: (context) => const DanbooruPoolTiles(),
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

class DanbooruRepository extends BooruRepositoryDefault {
  const DanbooruRepository({
    required this.ref,
  });

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
  FavoriteRepository favorite(BooruConfigAuth config) {
    return DanbooruFavoriteRepository(ref, config);
  }

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return DanbooruBlacklistTagRepository(
      ref,
      config,
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

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return DanbooruTagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator() {
    return const DanbooruGridThumbnailUrlGenerator();
  }

  @override
  TextMatcher queryMatcher(BooruConfigAuth config) {
    return ref.watch(danbooruQueryMatcherProvider);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder<DanbooruPost>(
      defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat:
          kBoorusamaBulkDownloadCustomFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
        TokenHandler('artist', (post, config) => post.artistTags.join(' ')),
        TokenHandler(
          'character',
          (post, config) => post.characterTags.join(' '),
        ),
        TokenHandler(
          'copyright',
          (post, config) => post.copyrightTags.join(' '),
        ),
        TokenHandler('general', (post, config) => post.generalTags.join(' ')),
        TokenHandler('meta', (post, config) => post.metaTags.join(' ')),
        MPixelsTokenHandler(),
      ],
    );
  }
}

BooruComponents createDanbooru() => BooruComponents(
      parser: DanbooruParser(),
      createBuilder: DanbooruBuilder.new,
      createRepository: (ref) => DanbooruRepository(ref: ref),
    );

typedef DanbooruSite = ({
  String url,
  bool? aiTagSupport,
  bool? censoredTagsBanned,
});

final class Danbooru extends Booru {
  const Danbooru({
    required super.name,
    required super.protocol,
    required List<DanbooruSite> sites,
  }) : _sites = sites;

  final List<DanbooruSite> _sites;

  @override
  Iterable<String> get sites => _sites.map((e) => e.url);

  @override
  BooruType get type => BooruType.danbooru;

  bool hasAiTagSupported(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.aiTagSupport ??
      false;

  bool hasCensoredTagsBanned(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.censoredTagsBanned ??
      false;

  String cheetsheet(String url) {
    return '$url/wiki_pages/help:cheatsheet';
  }
}

class DanbooruParser extends BooruParser {
  @override
  BooruType get booruType => BooruType.danbooru;

  @override
  Booru parse(String name, dynamic data) {
    final sites = <DanbooruSite>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final aiTagSupport = item['ai-tag'];
      final censoredTagsBanned = item['censored-tags-banned'];

      sites.add(
        (
          url: url,
          aiTagSupport: aiTagSupport,
          censoredTagsBanned: censoredTagsBanned,
        ),
      );
    }

    return Danbooru(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: sites,
    );
  }
}

class DanbooruGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DanbooruGridThumbnailUrlGenerator();

  @override
  String generateUrl(
    Post post, {
    required GridThumbnailSettings settings,
  }) {
    return castOrNull<DanbooruPost>(post).toOption().fold(
          () => const DefaultGridThumbnailUrlGenerator().generateUrl(
            post,
            settings: settings,
          ),
          (post) => DefaultGridThumbnailUrlGenerator(
            gifImageQualityMapper: (_, __) => post.sampleImageUrl,
            imageQualityMapper: (_, imageQuality) => switch (imageQuality) {
              ImageQuality.automatic => post.url720x720,
              ImageQuality.low => post.url360x360,
              ImageQuality.high => post.url720x720,
              ImageQuality.highest =>
                post.isVideo ? post.url720x720 : post.urlSample,
              ImageQuality.original => post.urlOriginal,
            },
          ).generateUrl(
            post,
            settings: settings,
          ),
        );
  }
}
