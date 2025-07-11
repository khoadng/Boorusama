// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/gesture/gesture.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/downloads/downloader/providers.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/home/custom_home.dart';
import '../../core/home/user_custom_home_builder.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/widgets.dart';
import '../../core/posts/listing/providers.dart';
import '../../core/posts/listing/widgets.dart';
import '../../core/posts/post/routes.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/shares/providers.dart';
import '../../core/posts/shares/widgets.dart';
import '../../core/posts/sources/source.dart';
import '../../core/posts/statistics/stats.dart';
import '../../core/posts/statistics/widgets.dart';
import '../../core/settings/settings.dart';
import '../../core/tags/metatag/providers.dart';
import '../../core/tags/tag/routes.dart';
import '../../foundation/url_launcher.dart';
import 'artists/artist/widgets.dart';
import 'artists/search/widgets.dart';
import 'autocompletes/widgets.dart';
import 'comments/listing/widgets.dart';
import 'configs/widgets.dart';
import 'forums/topics/widgets.dart';
import 'home/widgets.dart';
import 'posts/details/widgets.dart';
import 'posts/explores/widgets.dart';
import 'posts/favgroups/listing/widgets.dart';
import 'posts/favorites/widgets.dart';
import 'posts/listing/providers.dart';
import 'posts/listing/widgets.dart';
import 'posts/pools/listing/widgets.dart';
import 'posts/post/post.dart';
import 'posts/search/widgets.dart';
import 'posts/statistics/widgets.dart';
import 'posts/votes/providers.dart';
import 'saved_searches/feed/widgets.dart';
import 'tags/details/widgets.dart';
import 'tags/tag/widgets.dart';

class DanbooruBuilder
    with DefaultUnknownBooruWidgetsBuilderMixin
    implements BooruBuilder {
  DanbooruBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
      }) => CreateBooruConfigScope(
        id: id,
        config: BooruConfig.defaultConfig(
          booruType: id.booruType,
          url: id.url,
          customDownloadFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
        ),
        child: CreateDanbooruConfigPage(
          backgroundColor: backgroundColor,
        ),
      );

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const DanbooruHomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
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
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) =>
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
        onViewTags: () => goToShowTaglistPage(ref, post),
        onViewOriginal: () => goToOriginalImagePage(ref, post),
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
                      ImageQuality.original => post.sampleImageUrl,
                      _ => post.url720x720,
                    },
                    (quality) => switch (PostQualityType.parse(quality)) {
                      PostQualityType.v180x180 => post.url180x180,
                      PostQualityType.v360x360 => post.url360x360,
                      PostQualityType.v720x720 => post.url720x720,
                      PostQualityType.sample =>
                        post.isVideo ? post.url720x720 : post.sampleImageUrl,
                      PostQualityType.original =>
                        post.isVideo ? post.url720x720 : post.originalImageUrl,
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
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder =>
      () => {
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
      displayName: (context) => context.t.explore.explore,
      builder: (context, _) => const DanbooruExplorePage(),
    ),
    const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
      displayName: (context) => context.t.profile.favorites,
      builder: (context, _) => const DanbooruFavoritesPage(),
    ),
    const CustomHomeViewKey('artists'): CustomHomeDataBuilder(
      displayName: (context) => 'Artists'.hc,
      builder: (context, _) => const DanbooruArtistSearchPage(),
    ),
    const CustomHomeViewKey('forum'): CustomHomeDataBuilder(
      displayName: (context) => context.t.forum.forum,
      builder: (context, _) => const DanbooruForumPage(),
    ),
    const CustomHomeViewKey('favgroup'): CustomHomeDataBuilder(
      displayName: (context) => context.t.favorite_groups.favorite_groups,
      builder: (context, _) => const FavoriteGroupsPage(),
    ),
    const CustomHomeViewKey('saved_searches'): CustomHomeDataBuilder(
      displayName: (context) => context.t.saved_search.saved_search,
      builder: (context, _) => const SavedSearchFeedPage(),
    ),
    const CustomHomeViewKey('pools'): CustomHomeDataBuilder(
      displayName: (context) => 'Pools'.hc,
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
      DetailsPart.artistPosts: (context) =>
          const DefaultInheritedArtistPostsSection<DanbooruPost>(),
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

  @override
  ViewTagListBuilder get viewTagListBuilder =>
      (context, post, initiallyMultiSelectEnabled) {
        return DanbooruShowTagListPage(
          post: post,
          initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
        );
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
