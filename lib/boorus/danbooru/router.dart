// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_feed_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/routes.dart';
import 'package:boorusama/boorus/danbooru/ui/features/accounts/login/login_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/artists/artist_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/characters/character_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_create_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_update_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/original_image_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/parent_child_post_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/full_history_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/landing/favorite_tags/import_favorite_tag_dialog.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/result/related_tag_action_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/appearance_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/download_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/general_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/language_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/privacy_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/search_settings_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/settings_page_desktop.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'package:boorusama/core/ui/info_container.dart';
import 'package:boorusama/core/ui/widgets/parallax_slide_in_page_route.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'router_page_constant.dart';
import 'ui/features/post_detail/post_detail_page_desktop.dart';
import 'ui/features/saved_search/saved_search_feed_page.dart';

@immutable
class AppRouter {
  static final FluroRouter router = FluroRouter.appRouter;

  void setupRoutes() {
    router
      ..define('/', handler: rootHandler)
      ..define(
        '/artist',
        handler: artistHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/character',
        handler: characterHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/post/detail',
        handler: postDetailHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/posts/search',
        handler: postSearchHandler,
        transitionType: TransitionType.fadeIn,
      )
      ..define(
        '/users/profile',
        handler: userHandler,
        transitionType: TransitionType.inFromRight,
      )
      ..define(
        '/login',
        handler: loginHandler,
        transitionType: TransitionType.inFromRight,
      )
      ..define(
        '/settings',
        handler: settingsHandler,
        transitionType: TransitionType.inFromRight,
      )
      ..define(
        '/pool/detail',
        handler: poolDetailHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/favorites',
        handler: favoritesHandler,
        transitionType: TransitionType.inFromRight,
      )
      ..define(
        '/bulk_download',
        handler: bulkDownloadHandler,
        transitionType: TransitionType.inFromBottom,
      )
      ..define(
        '/saved_search',
        handler: savedSearchHandler,
        transitionType: TransitionType.inFromRight,
      )
      ..define(
        '/saved_search/edit',
        handler: savedSearchEditHandler,
        transitionType: TransitionType.inFromRight,
      )
      ..define(
        '/users/blacklisted_tags',
        handler: blacklistedTagsHandler,
        transitionType: TransitionType.inFromRight,
      );
  }
}

void goToArtistPage(BuildContext context, String artist) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/artist',
      routeSettings: RouteSettings(
        name: RouterPageConstant.artist,
        arguments: [
          artist,
          '',
        ],
      ),
    );
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PostBloc.of(context)
              ..add(PostRefreshed(
                tag: artist,
                fetcher: SearchedPostFetcher.fromTags(artist),
              )),
          ),
          BlocProvider.value(
            value: context.read<ArtistBloc>()..add(ArtistFetched(name: artist)),
          ),
        ],
        child: CustomContextMenuOverlay(
          child: ArtistPageDesktop(
            artistName: artist,
          ),
        ),
      ),
    );
  }
}

void goToCharacterPage(BuildContext context, String tag) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/character',
      routeSettings: RouteSettings(
        name: RouterPageConstant.character,
        arguments: [
          tag,
          '',
        ],
      ),
    );
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PostBloc.of(context)
              ..add(PostRefreshed(
                tag: tag,
                fetcher: SearchedPostFetcher.fromTags(tag),
              )),
          ),
          BlocProvider.value(
            value: context.read<WikiBloc>()..add(WikiFetched(tag: tag)),
          ),
        ],
        child: CustomContextMenuOverlay(
          child: CharacterPageDesktop(
            characterName: tag,
          ),
        ),
      ),
    );
  }
}

void goToProfilePage(BuildContext context) {
  AppRouter.router.navigateTo(
    context,
    '/users/profile',
    routeSettings: const RouteSettings(
      name: RouterPageConstant.profile,
    ),
  );
}

void goToFavoritesPage(BuildContext context, String? username) {
  AppRouter.router.navigateTo(
    context,
    '/favorites',
    routeSettings: RouteSettings(
      name: RouterPageConstant.favorties,
      arguments: [username],
    ),
  );
}

void goToBulkDownloadPage(BuildContext context, List<String>? tags) {
  AppRouter.router.navigateTo(
    context,
    '/bulk_download',
    routeSettings: RouteSettings(
      name: RouterPageConstant.bulkDownload,
      arguments: [
        tags,
      ],
    ),
  );
}

void goToPoolDetailPage(BuildContext context, Pool pool) {
  AppRouter.router.navigateTo(
    context,
    'pool/detail',
    routeSettings: RouteSettings(
      name: RouterPageConstant.poolDetails,
      arguments: [
        pool,
      ],
    ),
  );
}

void goToParentChildPage(
  BuildContext context,
  int parentId,
  String tagQueryForDataFetching,
) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.bottomToTop,
    settings: const RouteSettings(
      name: RouterPageConstant.parentChild,
    ),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PostBloc.of(context)
            ..add(PostRefreshed(
              tag: tagQueryForDataFetching,
              fetcher: SearchedPostFetcher.fromTags(
                tagQueryForDataFetching,
              ),
            )),
        ),
      ],
      child: CustomContextMenuOverlay(
        child: ParentChildPostPage(parentPostId: parentId),
      ),
    ),
  ));
}

void goToHomePage(
  BuildContext context, {
  bool replace = false,
}) {
  AppRouter.router.navigateTo(
    context,
    '/',
    routeSettings: const RouteSettings(
      name: RouterPageConstant.home,
    ),
    clearStack: true,
    replace: replace,
  );
}

void goToDetailPage({
  required BuildContext context,
  required List<PostData> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
  PostBloc? postBloc,
}) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/post/detail',
      routeSettings: RouteSettings(
        name: RouterPageConstant.postDetails,
        arguments: [
          posts,
          initialIndex,
          scrollController,
          postBloc,
        ],
      ),
    );
  } else {
    showDesktopFullScreenWindow(context, builder: (context) {
      final tags = posts
          .map((e) => e.post)
          .map((p) => [
                ...p.artistTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.artist.stringify(),
                      postId: p.id,
                    )),
                ...p.characterTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.charater.stringify(),
                      postId: p.id,
                    )),
                ...p.copyrightTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.copyright.stringify(),
                      postId: p.id,
                    )),
                ...p.generalTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.general.stringify(),
                      postId: p.id,
                    )),
                ...p.metaTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.meta.stringify(),
                      postId: p.id,
                    )),
              ])
          .expand((e) => e)
          .toList();

      return BlocSelector<SettingsCubit, SettingsState, Settings>(
        selector: (state) => state.settings,
        builder: (context, settings) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AuthenticationCubit>()),
              BlocProvider.value(value: context.read<ApiEndpointCubit>()),
              BlocProvider.value(value: context.read<ThemeBloc>()),
              BlocProvider(
                create: (context) => PostDetailBloc(
                  noteRepository: context.read<NoteRepository>(),
                  defaultDetailsStyle: settings.detailsDisplay,
                  posts: posts,
                  initialIndex: initialIndex,
                  postRepository: context.read<PostRepository>(),
                  favoritePostRepository:
                      context.read<FavoritePostRepository>(),
                  accountRepository: context.read<AccountRepository>(),
                  postVoteRepository: context.read<PostVoteRepository>(),
                  tags: tags,
                  tagCache: {},
                ),
              ),
            ],
            child: RepositoryProvider.value(
              value: context.read<TagRepository>(),
              child: PostDetailPageDesktop(
                intitialIndex: initialIndex,
                posts: posts,
              ),
            ),
          );
        },
      );
    });
  }
}

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/posts/search',
      routeSettings: RouteSettings(
        name: RouterPageConstant.search,
        arguments: [tag ?? ''],
      ),
    );
  } else {
    showDesktopFullScreenWindow(context, builder: (context) {
      return BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
        builder: (context, state) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final tagSearchBloc = TagSearchBloc(
                tagInfo: context.read<TagInfo>(),
                autocompleteRepository: context.read<AutocompleteRepository>(),
              );

              final postBloc = PostBloc.of(
                context,
                pagination:
                    settingsState.settings.contentOrganizationCategory ==
                        ContentOrganizationCategory.pagination,
              );
              final searchHistoryCubit = SearchHistoryBloc(
                searchHistoryRepository:
                    context.read<SearchHistoryRepository>(),
              );
              final relatedTagBloc = RelatedTagBloc(
                relatedTagRepository: context.read<RelatedTagRepository>(),
              );
              final searchHistorySuggestions = SearchHistorySuggestionsBloc(
                searchHistoryRepository:
                    context.read<SearchHistoryRepository>(),
              );

              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: searchHistoryCubit),
                  BlocProvider.value(
                    value: context.read<FavoriteTagBloc>()
                      ..add(const FavoriteTagFetched()),
                  ),
                  BlocProvider.value(value: postBloc),
                  BlocProvider.value(
                    value: BlocProvider.of<ThemeBloc>(context),
                  ),
                  BlocProvider.value(value: searchHistorySuggestions),
                  BlocProvider(
                    create: (context) => SearchBloc(
                      initial: DisplayState.options,
                      metatags: context.read<TagInfo>().metatags,
                      tagSearchBloc: tagSearchBloc,
                      searchHistoryBloc: searchHistoryCubit,
                      relatedTagBloc: relatedTagBloc,
                      searchHistorySuggestionsBloc: searchHistorySuggestions,
                      postBloc: postBloc,
                      postCountRepository: context.read<PostCountRepository>(),
                      initialQuery: tag,
                      booruType: state.booru.booruType,
                    ),
                  ),
                  BlocProvider.value(value: relatedTagBloc),
                ],
                child: CustomContextMenuOverlay(
                  child: SearchPageDesktop(
                    metatags: context.read<TagInfo>().metatags,
                    metatagHighlightColor:
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}

void goToSettingPage(BuildContext context) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/settings',
      routeSettings: const RouteSettings(
        name: RouterPageConstant.settings,
      ),
    );
  } else {
    showDesktopDialogWindow(
      context,
      width: min(MediaQuery.of(context).size.width * 0.8, 900),
      height: min(MediaQuery.of(context).size.height * 0.8, 650),
      builder: (context) => const SettingsPageDesktop(),
    );
  }
}

Future<T?> showDesktopDialogWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  double? width,
  double? height,
  Color? backgroundColor,
  EdgeInsets? margin,
  RouteSettings? settings,
}) =>
    showGeneralDialog(
      context: context,
      routeSettings: settings,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      pageBuilder: (context, _, __) {
        return Dialog(
          backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            width: width ?? MediaQuery.of(context).size.width * 0.8,
            height: height ?? MediaQuery.of(context).size.height * 0.8,
            margin: margin ??
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: builder(context),
          ),
        );
      },
    );

Future<T?> showDesktopFullScreenWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) =>
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return builder(context);
      },
    );

void goToLoginPage(BuildContext context) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/login',
      routeSettings: const RouteSettings(
        name: RouterPageConstant.login,
      ),
    );
  } else {
    showDesktopDialogWindow(
      context,
      width: min(MediaQuery.of(context).size.width * 0.8, 1000),
      height: min(MediaQuery.of(context).size.height * 0.8, 700),
      builder: (context) => const LoginPageDesktop(),
    );
  }
}

void goToExploreDetailPage(
  BuildContext context,
  DateTime? date,
  String title,
  ExploreCategory category,
) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(
          name: () {
            switch (category) {
              case ExploreCategory.popular:
                return RouterPageConstant.explorePopular;
              case ExploreCategory.mostViewed:
                return RouterPageConstant.exploreMostViewed;
              case ExploreCategory.hot:
                return RouterPageConstant.exploreHot;
            }
          }(),
        ),
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ExploreDetailBloc(initialDate: date),
            ),
            BlocProvider(
              create: (context) => PostBloc.of(context)
                ..add(
                  PostRefreshed(
                    fetcher: categoryToFetcher(
                      category,
                      date ?? DateTime.now(),
                      TimeScale.day,
                      context,
                    ),
                  ),
                ),
            ),
          ],
          child: CustomContextMenuOverlay(
            child: ExploreDetailPage(
              title: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              category: category,
            ),
          ),
        ),
      ),
    );
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ExploreDetailBloc(initialDate: date),
          ),
          BlocProvider(
            create: (context) => PostBloc.of(context)
              ..add(
                PostRefreshed(
                  fetcher: categoryToFetcher(
                    category,
                    date ?? DateTime.now(),
                    TimeScale.day,
                    context,
                  ),
                ),
              ),
          ),
        ],
        child: CustomContextMenuOverlay(
          child: ExploreDetailPage(
            title: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            category: category,
          ),
        ),
      ),
    );
  }
}

void goToSavedSearchPage(BuildContext context, String? username) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/saved_search',
      routeSettings: RouteSettings(
        name: RouterPageConstant.savedSearch,
        arguments: [username],
      ),
    );
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PostBloc.of(context),
          ),
          BlocProvider(
            create: (context) => SavedSearchFeedBloc(
              savedSearchBloc: context.read<SavedSearchBloc>(),
            )..add(const SavedSearchFeedRefreshed()),
          ),
        ],
        child: const CustomContextMenuOverlay(child: SavedSearchFeedPage()),
      ),
    );
  }
}

void goToSavedSearchEditPage(BuildContext context) {
  AppRouter.router.navigateTo(
    context,
    '/saved_search/edit',
    routeSettings: const RouteSettings(
      name: RouterPageConstant.savedSearchEdit,
    ),
  );
}

void goToBlacklistedTagPage(BuildContext context) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/users/blacklisted_tags',
      routeSettings: const RouteSettings(
        name: RouterPageConstant.blacklistedTags,
      ),
    );
  } else {
    showDesktopDialogWindow(
      context,
      width: min(MediaQuery.of(context).size.width * 0.8, 700),
      height: min(MediaQuery.of(context).size.height * 0.8, 600),
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: BlocProvider.of<BlacklistedTagsBloc>(context)
              ..add(const BlacklistedTagRequested()),
          ),
        ],
        child: const BlacklistedTagsPageDesktop(),
      ),
    );
  }
}

void goToOriginalImagePage(BuildContext context, Post post) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.fade,
    settings: const RouteSettings(
      name: RouterPageConstant.originalImage,
    ),
    child: OriginalImagePage(
      post: post,
      initialOrientation: MediaQuery.of(context).orientation,
    ),
  ));
}

void goToSettingsGeneral(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(ParallaxSlideInPageRoute(
    enterWidget: const GeneralPage(),
    oldWidget: oldWidget,
    settings: const RouteSettings(
      name: RouterPageConstant.settingsGeneral,
    ),
  ));
}

void goToSettingsAppearance(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const AppearancePage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsAppearance,
      ),
    ),
  );
}

void goToSettingsLanguage(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const LanguagePage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsLanguage,
      ),
    ),
  );
}

void goToSettingsDownload(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const DownloadPage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsDownload,
      ),
    ),
  );
}

void goToSettingsSearch(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const SearchSettingsPage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsSearch,
      ),
    ),
  );
}

void goToSettingsPrivacy(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const PrivacyPage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsPrivacy,
      ),
    ),
  );
}

void goToChanglog(BuildContext context) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.settingsChangelog,
    ),
    pageBuilder: (context, __, ___) => Scaffold(
      appBar: AppBar(
        title: const Text('settings.changelog').tr(),
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              size: 24,
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('CHANGELOG.md'),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Markdown(
                  data: snapshot.data!,
                )
              : const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
        },
      ),
    ),
  );
}

void goToAppAboutPage(BuildContext context) {
  showAboutDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.settingsInformation,
    ),
    applicationIcon: Image.asset(
      'assets/icon/icon-512x512.png',
      width: 64,
      height: 64,
    ),
    applicationVersion: getVersion(
      RepositoryProvider.of<PackageInfoProvider>(
        context,
      ).getPackageInfo(),
    ),
    applicationLegalese: '\u{a9} 2020-2023 Nguyen Duc Khoa',
    applicationName: context.read<AppInfoProvider>().appInfo.appName,
  );
}

void goToBlacklistedTagsSearchPage(
  BuildContext context, {
  required void Function(List<TagSearchItem> tags) onSelectDone,
  required Widget oldWidget,
  List<String>? initialTags,
}) {
  Navigator.of(context).push(ParallaxSlideInPageRoute(
    enterWidget: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TagSearchBloc(
            tagInfo: context.read<TagInfo>(),
            autocompleteRepository: context.read<AutocompleteRepository>(),
          ),
        ),
      ],
      child: BlacklistedTagsSearchPage(
        initialTags: initialTags,
        onSelectedDone: onSelectDone,
      ),
    ),
    oldWidget: oldWidget,
    settings: const RouteSettings(
      name: RouterPageConstant.blacklistedSearch,
    ),
  ));
}

void goToCommentPage(BuildContext context, int postId) {
  showCommentPage(
    context,
    postId: postId,
    settings: const RouteSettings(
      name: RouterPageConstant.comment,
    ),
  );
}

void goToCommentCreatePage(
  BuildContext context, {
  required int postId,
  String? initialContent,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => CommentCreatePage(
      postId: postId,
      initialContent: initialContent,
    ),
    settings: const RouteSettings(
      name: RouterPageConstant.commentCreate,
    ),
  ));
}

void goToCommentUpdatePage(
  BuildContext context, {
  required int postId,
  required int commentId,
  required String commentBody,
  String? initialContent,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => CommentUpdatePage(
        postId: postId,
        commentId: commentId,
        initialContent: commentBody,
      ),
      settings: const RouteSettings(
        name: RouterPageConstant.commentUpdate,
      ),
    ),
  );
}

void goToPoolSearchPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PoolBloc(
            poolRepository: context.read<PoolRepository>(),
            postRepository: context.read<PostRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => PoolSearchBloc(
            poolRepository: context.read<PoolRepository>(),
          ),
        ),
      ],
      child: const PoolSearchPage(),
    ),
    settings: const RouteSettings(
      name: RouterPageConstant.poolSearch,
    ),
  ));
}

void goToQuickSearchPage(
  BuildContext context, {
  bool ensureValidTag = false,
  Widget Function(String text)? floatingActionButton,
  required void Function(AutocompleteData tag) onSelected,
  void Function(BuildContext context, String text)? onSubmitted,
}) {
  showSimpleTagSearchView(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.quickSearch,
    ),
    ensureValidTag: ensureValidTag,
    floatingActionButton: floatingActionButton,
    onSubmitted: onSubmitted,
    onSelected: onSelected,
  );
}

void goToRelatedTagsPage(
  BuildContext context, {
  required RelatedTag relatedTag,
}) {
  final bloc = context.read<SearchBloc>();
  final page = BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
    builder: (context, state) {
      return RelatedTagActionSheet(
        relatedTag: relatedTag,
        onOpenWiki: (tag) => launchWikiPage(
          state.booru.url,
          tag,
        ),
        onAddToSearch: (tag) => bloc.add(SearchRelatedTagSelected(tag: tag)),
      );
    },
  );
  if (Screen.of(context).size == ScreenSize.small) {
    showBarModalBottomSheet(
      context: context,
      settings: const RouteSettings(
        name: RouterPageConstant.relatedTags,
      ),
      builder: (context) => page,
    );
  } else {
    showSideSheetFromRight(
      settings: const RouteSettings(
        name: RouterPageConstant.relatedTags,
      ),
      width: 220,
      body: page,
      context: context,
    );
  }
}

void goToMetatagsPage(
  BuildContext context, {
  required List<Metatag> metatags,
  required void Function(Metatag tag) onSelected,
}) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.metatags,
    ),
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: const Text('Metatags'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          InfoContainer(
            contentBuilder: (context) =>
                const Text('search.metatags_notice').tr(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: metatags.length,
              itemBuilder: (context, index) {
                final tag = metatags[index];

                return ListTile(
                  onTap: () => onSelected(tag),
                  title: Text(tag.name),
                  trailing: tag.isFree ? const Chip(label: Text('Free')) : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void goToPostFavoritesDetails(BuildContext context, Post post) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.postFavoriters,
    ),
    height: MediaQuery.of(context).size.height * 0.65,
    builder: (context) => BlocProvider(
      create: (context) => PostFavoriteBloc(
        favoritePostRepository: context.read<FavoritePostRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(PostFavoriteFetched(
          postId: post.id,
          refresh: true,
        )),
      child: FavoriterDetailsView(
        post: post,
      ),
    ),
  );
}

void goToPostVotesDetails(BuildContext context, Post post) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.postVoters,
    ),
    height: MediaQuery.of(context).size.height * 0.65,
    builder: (context) => BlocProvider(
      create: (context) => PostVoteInfoBloc(
        postVoteRepository: context.read<PostVoteRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(PostVoteInfoFetched(
          postId: post.id,
          refresh: true,
        )),
      child: VoterDetailsView(
        post: post,
      ),
    ),
  );
}

void goToSavedSearchQuickUpdatePage(BuildContext context) {
  final bloc = context.read<SavedSearchBloc>();

  if (isMobilePlatform()) {
    showMaterialModalBottomSheet(
      context: context,
      settings: const RouteSettings(
        name: RouterPageConstant.savedSearchQuickUpdate,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      builder: (_) => EditSavedSearchSheet(
        onSubmit: (query, label) => bloc.add(SavedSearchCreated(
          query: query,
          label: label,
          onCreated: (data) => showSimpleSnackBar(
            context: context,
            duration: const Duration(seconds: 1),
            content: const Text('saved_search.saved_search_added').tr(),
          ),
        )),
      ),
    );
  } else {
    showGeneralDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: RouterPageConstant.savedSearchQuickUpdate,
      ),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      pageBuilder: (context, _, __) {
        return Dialog(
          backgroundColor: Theme.of(context).backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            margin: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: EditSavedSearchSheet(
              onSubmit: (query, label) => bloc.add(SavedSearchCreated(
                query: query,
                label: label,
                onCreated: (data) => showSimpleSnackBar(
                  context: context,
                  duration: const Duration(seconds: 1),
                  content: const Text('saved_search.saved_search_added').tr(),
                ),
              )),
            ),
          ),
        );
      },
    );
  }
}

Future<Object?> goToFavoriteTagImportPage(
  BuildContext context,
  FavoriteTagBloc bloc,
) {
  return showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.favoriteTagsImport,
    ),
    pageBuilder: (context, _, __) => ImportFavoriteTagsDialog(
      padding: isMobilePlatform() ? 0 : 8,
      onImport: (tagString) => bloc.add(FavoriteTagImported(
        tagString: tagString,
      )),
    ),
  );
}

void goToImagePreviewPage(BuildContext context, Post post) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.postQuickPreview,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => QuickPreviewImage(
      child: BooruImage(
        placeholderUrl: post.previewImageUrl,
        aspectRatio: post.aspectRatio,
        imageUrl: post.normalImageUrl,
        previewCacheManager: context.read<PreviewImageCacheManager>(),
      ),
    ),
  );
}

void goToSearchHistoryPage(
  BuildContext context, {
  required Function() onClear,
  required Function(SearchHistory history) onRemove,
  required Function(String history) onTap,
}) {
  final bloc = context.read<SearchHistoryBloc>();

  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    duration: const Duration(milliseconds: 200),
    builder: (context) => BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('search.history.history').tr(),
            actions: [
              TextButton(
                onPressed: () => onClear(),
                child: const Text('search.history.clear').tr(),
              ),
            ],
          ),
          body: FullHistoryView(
            onHistoryTap: (value) => onTap(value),
            onHistoryRemoved: (value) => onRemove(value),
            histories: state.histories,
          ),
        );
      },
    ),
  );
}
