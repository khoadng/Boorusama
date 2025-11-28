// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/home/types.dart';
import '../../core/home/widgets.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/listing/providers.dart';
import '../../core/posts/listing/widgets.dart';
import '../../core/posts/statistics/types.dart';
import '../../core/posts/statistics/widgets.dart';
import 'artists/artist/widgets.dart';
import 'autocompletes/widgets.dart';
import 'comments/listing/widgets.dart';
import 'configs/widgets.dart';
import 'home/types.dart';
import 'home/widgets.dart';
import 'posts/details/widgets.dart';
import 'posts/favorites/widgets.dart';
import 'posts/listing/widgets.dart';
import 'posts/post/types.dart';
import 'posts/restoration/widgets.dart';
import 'posts/search/widgets.dart';
import 'posts/statistics/widgets.dart';
import 'tags/details/widgets.dart';
import 'tags/tag/widgets.dart';

class DanbooruBuilder extends BaseBooruBuilder {
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
      (context, useAppBar, post) => CommentPage(
        postId: post.id,
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
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      danbooruCustomHome;

  @override
  final postDetailsUIBuilder = danbooruPostDetailsUiBuilder;

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

  @override
  SessionRestoreBuilder? get sessionRestoreBuilder => (context, snapshot) {
    return DanbooruSessionRestorePage(
      snapshot: snapshot,
    );
  };
}
