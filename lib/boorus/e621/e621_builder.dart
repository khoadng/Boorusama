// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/config/providers.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/home/custom_home.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/search/search/widgets.dart';
import 'artists/widgets.dart';
import 'comments/widgets.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/widgets.dart';
import 'popular/widgets.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class E621Builder
    with
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultUnknownBooruWidgetsBuilderMixin,
        DefaultViewTagListBuilderMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultQuickFavoriteButtonBuilderMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostImageDetailsUrlMixin
    implements BooruBuilder {
  E621Builder();

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
        child: CreateE621ConfigPage(
          backgroundColor: backgroundColor,
        ),
      );

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const E621HomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
        id: id,
        child: CreateE621ConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
        ),
      );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => E621SearchPage(
        params: params,
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    final posts = payload.posts.map((e) => e as E621Post).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<E621Post>(),
    );
  };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const E621FavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => E621ArtistPage(artistName: artistName);

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => E621CommentPage(
        postId: postId,
        useAppBar: useAppBar,
      );

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      ke621AltHomeView;

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<E621Post>(
            showSource: true,
          ),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<E621Post>(),
    },
    full: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<E621Post>(
            showSource: true,
          ),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<E621Post>(),
      DetailsPart.artistInfo: (context) => const E621ArtistSection(),
      DetailsPart.tags: (context) => const DefaultInheritedTagsTile<E621Post>(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<E621Post>(),
      DetailsPart.artistPosts: (context) =>
          const DefaultInheritedArtistPostsSection<E621Post>(),
    },
  );
}

final ke621AltHomeView = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: (context) => context.t.profile.favorites,
    builder: (context, _) => const E621FavoritesPage(),
  ),
  const CustomHomeViewKey('popular'): CustomHomeDataBuilder(
    displayName: (context) => 'Popular'.hc,
    builder: (context, _) => const E621PopularPage(),
  ),
};

class E621SearchPage extends ConsumerWidget {
  const E621SearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(e621PostRepoProvider(config));

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
    );
  }
}
