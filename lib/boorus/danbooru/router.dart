// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
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
import 'package:boorusama/boorus/danbooru/routes.dart';
import 'package:boorusama/boorus/danbooru/ui/features/accounts/login/login_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/artists/artist_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/characters/character_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_detail_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/original_image_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/parent_child_post_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/settings_page_desktop.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
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

const _artist = 'artist';
const _character = 'character';
const _home = 'home';
const _postDetails = 'post/details';
const _settings = 'settings';
const _blacklisted = 'blacklisted_tags';
const _savedSearch = 'saved_search';
const _savedSearchEdit = 'saved_search/edit';
const _profile = 'profile';
const _favorties = 'favorites';
const _bulkDownload = 'bulk_download';
const _poolDetails = 'pool_details';
const _search = 'search';
const _login = 'login';
const _explorePopular = 'explore/popular';
const _exploreHot = 'explore/hot';
const _exploreMostViewed = 'explore/most_viewed';
const _image = 'image';
const _parentChild = 'post/child';

void goToArtistPage(BuildContext context, String artist) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/artist',
      routeSettings: RouteSettings(
        name: _artist,
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
        name: _character,
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
      name: _profile,
    ),
  );
}

void goToFavoritesPage(BuildContext context, String? username) {
  AppRouter.router.navigateTo(
    context,
    '/favorites',
    routeSettings: RouteSettings(
      name: _favorties,
      arguments: [username],
    ),
  );
}

void goToBulkDownloadPage(BuildContext context, List<String>? tags) {
  AppRouter.router.navigateTo(
    context,
    '/bulk_download',
    routeSettings: RouteSettings(
      name: _bulkDownload,
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
      name: _poolDetails,
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
      name: _parentChild,
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
      name: _home,
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
        name: _postDetails,
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
        name: _search,
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
        name: _settings,
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
}) =>
    showGeneralDialog(
      context: context,
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
        name: _login,
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
                return _explorePopular;
              case ExploreCategory.mostViewed:
                return _exploreMostViewed;
              case ExploreCategory.hot:
                return _exploreHot;
            }
          }(),
        ),
        builder: (context) => BlocProvider(
          create: (context) => ExploreDetailBloc(initialDate: date),
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
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => BlocProvider(
        create: (context) => ExploreDetailBloc(initialDate: date),
        child: ExploreDetailPageDesktop(
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
    );
  }
}

void goToSavedSearchPage(BuildContext context, String? username) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/saved_search',
      routeSettings: RouteSettings(
        name: _savedSearch,
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
      name: _savedSearchEdit,
    ),
  );
}

void goToBlacklistedTagPage(BuildContext context) {
  if (isMobilePlatform()) {
    AppRouter.router.navigateTo(
      context,
      '/users/blacklisted_tags',
      routeSettings: const RouteSettings(
        name: _blacklisted,
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
      name: _image,
    ),
    child: OriginalImagePage(
      post: post,
      initialOrientation: MediaQuery.of(context).orientation,
    ),
  ));
}
