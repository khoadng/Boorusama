// Project imports:
import '../../../configs/config/types.dart';
import '../../../configs/create/widgets.dart';
import '../../../configs/manage/widgets.dart';
import '../../../downloads/filename/types.dart';
import '../../../home/types.dart';
import '../../../home/widgets.dart';
import '../../../posts/details/widgets.dart';
import '../../../posts/details_parts/types.dart';
import '../../../posts/details_parts/widgets.dart';
import '../../../posts/favorites/widgets.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/statistics/types.dart';
import '../../../posts/statistics/widgets.dart';
import '../../../search/search/widgets.dart';
import '../../../search/suggestions/widgets.dart';
import '../../../tags/show/widgets.dart';
import '../../engine/types.dart';

class BaseBooruBuilder implements BooruBuilder {
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
        child: CreateAnonConfigPage(
          backgroundColor: backgroundColor,
        ),
      );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
        id: id,
        child: CreateAnonConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
        ),
      );

  @override
  PostDetailsUIBuilder get postDetailsUIBuilder =>
      kFallbackPostDetailsUIBuilder;

  @override
  FavoritesPageBuilder? get favoritesPageBuilder => null;
  @override
  QuickFavoriteButtonBuilder get quickFavoriteButtonBuilder =>
      (context, post) => DefaultQuickFavoriteButton(
        post: post,
      );

  @override
  ArtistPageBuilder? get artistPageBuilder => null;
  @override
  CharacterPageBuilder? get characterPageBuilder => null;
  @override
  CommentPageBuilder? get commentPageBuilder => null;

  @override
  TagSuggestionItemBuilder get tagSuggestionItemBuilder =>
      (config, tag, dense, currentQuery, onItemTap) => DefaultTagSuggestionItem(
        config: config,
        tag: tag,
        onItemTap: onItemTap,
        currentQuery: currentQuery,
        dense: dense,
      );

  @override
  PostStatisticsPageBuilder get postStatisticsPageBuilder =>
      (context, posts) => PostStatisticsPage(
        generalStats: () => posts.getStats(),
        totalPosts: () => posts.length,
      );

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const DefaultUnknownBooruWidgets();

  @override
  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder =>
      (context, controller, postController) => DefaultMultiSelectionActions(
        postController: postController,
      );

  @override
  HomeViewBuilder get homeViewBuilder =>
      (context) => const UserCustomHomeBuilder(
        defaultView: MobileHomePageScaffold(),
      );

  @override
  final Map<CustomHomeViewKey, CustomHomeDataBuilder> customHomeViewBuilders =
      kDefaultAltHomeView;

  @override
  ViewTagListBuilder get viewTagListBuilder =>
      (context, post, initiallyMultiSelectEnabled, auth) => ShowTagListPage(
        post: post,
        initiallyMultiSelectEnabled: initiallyMultiSelectEnabled,
        auth: auth,
      );

  @override
  VideoQualitySelectionBuilder? get videoQualitySelectionBuilder => null;

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const HomePageScaffold();

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => DefaultSearchPage(
        params: params,
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: payload.posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage(),
    );
  };

  @override
  SessionRestoreBuilder? get sessionRestoreBuilder => null;
}

final kFallbackPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) => const DefaultInheritedPostActionToolbar(),
  },
  full: {
    DetailsPart.toolbar: (context) => const DefaultInheritedPostActionToolbar(),
    DetailsPart.tags: (context) => const DefaultInheritedBasicTagsTile(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection(),
  },
);
