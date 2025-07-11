// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/comments/widgets.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/home/custom_home.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/search/search/widgets.dart';
import 'artists/widgets.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/widgets.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class GelbooruV2Builder
    with
        FavoriteNotSupportedMixin,
        UnknownMetatagsMixin,
        DefaultUnknownBooruWidgetsBuilderMixin,
        DefaultViewTagListBuilderMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin
    implements BooruBuilder {
  GelbooruV2Builder();

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
          customDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
        ),
        child: CreateGelbooruV2ConfigPage(
          backgroundColor: backgroundColor,
        ),
      );

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const GelbooruV2HomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
        id: id,
        child: CreateGelbooruV2ConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
        ),
      );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => GelbooruV2SearchPage(
        params: params,
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    final posts = payload.posts.map((e) => e as GelbooruV2Post).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<GelbooruV2Post>(),
    );
  };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const GelbooruV2FavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => GelbooruV2ArtistPage(
        artistName: artistName,
      );

  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => GelbooruV2ArtistPage(
        artistName: characterName,
      );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => CommentPageScaffold(
        postId: postId,
        useAppBar: useAppBar,
      );

  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder =>
      () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
      };

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      kGelbooruV2AltHomeView;

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<GelbooruV2Post>(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<GelbooruV2Post>(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<GelbooruV2Post>(),
      DetailsPart.tags: (context) =>
          const DefaultInheritedTagsTile<GelbooruV2Post>(),
      DetailsPart.fileDetails: (context) =>
          const GelbooruV2FileDetailsSection(),
      DetailsPart.artistPosts: (context) =>
          const DefaultInheritedArtistPostsSection<GelbooruV2Post>(),
      DetailsPart.relatedPosts: (context) =>
          const GelbooruV2RelatedPostsSection(),
      DetailsPart.characterList: (context) =>
          const DefaultInheritedCharacterPostsSection<GelbooruV2Post>(),
    },
  );
}

final kGelbooruV2AltHomeView = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: (context) => context.t.profile.favorites,
    builder: (context, _) => const GelbooruV2FavoritesPage(),
  ),
};

class GelbooruV2SearchPage extends ConsumerWidget {
  const GelbooruV2SearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(gelbooruV2PostRepoProvider(config));

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
    );
  }
}
