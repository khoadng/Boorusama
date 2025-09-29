// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/home/custom_home.dart';
import '../../core/home/user_custom_home_builder.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/listing/providers.dart';
import '../../core/posts/listing/widgets.dart';
import '../../core/posts/statistics/stats.dart';
import '../../core/posts/statistics/widgets.dart';
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
import 'posts/listing/widgets.dart';
import 'posts/pools/listing/widgets.dart';
import 'posts/post/post.dart';
import 'posts/search/widgets.dart';
import 'posts/statistics/widgets.dart';
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
  HomeViewBuilder get homeViewBuilder => (context) {
    return const UserCustomHomeBuilder(
      defaultView: LatestView(),
    );
  };

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
                postController: postController,
              )
            : DefaultMultiSelectionActions(
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
      displayName: (context) => context.t.artists.title,
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
      displayName: (context) => context.t.pool.pools,
      builder: (context, _) => const DanbooruPoolPage(),
    ),
  };

  @override
  final postDetailsUIBuilder = PostDetailsUIBuilder(
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
      (context, post, initiallyMultiSelectEnabled, auth) {
        return DanbooruShowTagListPage(
          post: post,
          initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
          auth: auth,
        );
      };
}
