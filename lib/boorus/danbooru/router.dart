// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/application/searches/danbooru_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/application/users.dart';
import 'package:boorusama/boorus/danbooru/application/wikis.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/ui/artists/danbooru_artist_page.dart';
import 'package:boorusama/boorus/danbooru/ui/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/ui/blacklisted_tags/blacklisted_tags_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/characters/character_page.dart';
import 'package:boorusama/boorus/danbooru/ui/characters/character_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/comment/comment_create_page.dart';
import 'package:boorusama/boorus/danbooru/ui/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/ui/comment/comment_update_page.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_hot_page.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_most_viewed_page.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_popular_page.dart';
import 'package:boorusama/boorus/danbooru/ui/favorites/add_to_favorite_group_page.dart';
import 'package:boorusama/boorus/danbooru/ui/favorites/create_favorite_group_dialog.dart';
import 'package:boorusama/boorus/danbooru/ui/favorites/favorite_group_details_page.dart';
import 'package:boorusama/boorus/danbooru/ui/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/ui/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/ui/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/pool/pool_page.dart';
import 'package:boorusama/boorus/danbooru/ui/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/saved_search/saved_search_feed_page.dart';
import 'package:boorusama/boorus/danbooru/ui/saved_search/saved_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/search/result/related_tag_action_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/search/search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/users/user_details_page.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/search/tag_store_scope.dart';
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/blacklists.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'package:boorusama/core/utils.dart';
import 'router_page_constant.dart';

void goToArtistPage(BuildContext context, String artist) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => provideArtistPageDependencies(
        context,
        artist: artist,
        page: DanbooruArtistPage(
          artistName: artist,
          backgroundImageUrl: '',
        ),
      ),
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (_) => provideArtistPageDependencies(
        context,
        artist: artist,
        page: DanbooruArtistPage(
          artistName: artist,
          backgroundImageUrl: '',
        ),
      ),
    );
  }
}

Widget provideArtistPageDependencies(
  BuildContext context, {
  required String artist,
  required Widget page,
}) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (dcontext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: dcontext.read<ArtistBloc>()
                  ..add(ArtistFetched(name: artist)),
              ),
            ],
            child: CustomContextMenuOverlay(
              child: page,
            ),
          );
        },
      );
    },
  );
}

void goToCharacterPage(BuildContext context, String tag) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => provideCharacterPageDependencies(
        context,
        character: tag,
        page: CharacterPage(
          characterName: tag,
          backgroundImageUrl: '',
        ),
      ),
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => provideCharacterPageDependencies(
        context,
        character: tag,
        page: CharacterPageDesktop(
          characterName: tag,
        ),
      ),
    );
  }
}

Widget provideCharacterPageDependencies(
  BuildContext context, {
  required String character,
  required Widget page,
}) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (dcontext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: dcontext.read<WikiBloc>()
                  ..add(WikiFetched(tag: character)),
              ),
            ],
            child: CustomContextMenuOverlay(
              child: page,
            ),
          );
        },
      );
    },
  );
}

void goToFavoritesPage(BuildContext context, String? username) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => FavoritesPage.of(context, username: username!),
  ));
}

void goToPoolDetailPage(BuildContext context, Pool pool) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) {
      return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
        builder: (_, state) {
          return DanbooruProvider.of(
            context,
            booru: state.booru!,
            builder: (dcontext) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: PoolDescriptionBloc(
                    endpoint: state.booru!.url,
                    poolDescriptionRepository:
                        dcontext.read<PoolDescriptionRepository>(),
                  )..add(PoolDescriptionFetched(poolId: pool.id)),
                ),
              ],
              child: CustomContextMenuOverlay(
                child: PoolDetailPage(
                  pool: pool,
                  postIds: QueueList.from(pool.postIds.reversed.skip(20)),
                ),
              ),
            ),
          );
        },
      );
    },
  ));
}

Future<void> goToDetailPage({
  required BuildContext context,
  required List<DanbooruPost> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
  bool hero = false,
  // PostBloc? postBloc,
}) {
  return Navigator.of(context).push(DanbooruPostDetailsPage.routeOf(
    context,
    posts: posts,
    scrollController: scrollController,
    initialIndex: initialIndex,
    hero: hero,
  ));
  // showDesktopFullScreenWindow(
  //   context,
  //   builder: (_) => providePostDetailPageDependencies(
  //     context,
  //     posts,
  //     initialIndex,
  //     tags,
  //     scrollController,
  //     PostDetailPageDesktop(
  //       intitialIndex: initialIndex,
  //       posts: posts,
  //     ),
  //   ),
  // );
}

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(PageTransition(
      type: PageTransitionType.fade,
      child: provideSearchPageDependencies(
        context,
        tag,
        (context) => SearchPage(
          metatags: context.read<TagInfo>().metatags,
          metatagHighlightColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    ));
  }
  // else {
  // showDesktopFullScreenWindow(
  //   context,
  //   builder: (_) => provideSearchPageDependencies(
  //     context,
  //     tag,
  //     (context) => SearchPageDesktop(
  //       metatags: context.read<TagInfo>().metatags,
  //       metatagHighlightColor: Theme.of(context).colorScheme.primary,
  //     ),
  //   ),
  // );
  // }
}

Widget provideSearchPageDependencies(
  BuildContext context,
  String? tag,
  Widget Function(BuildContext context) childBuilder,
) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return TagStoreScope(
        builder: (tagStore) => DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (context) {
            final searchHistoryCubit = SearchHistoryBloc(
              searchHistoryRepository: context.read<SearchHistoryRepository>(),
            );
            final relatedTagBloc = RelatedTagBloc(
              relatedTagRepository: context.read<RelatedTagRepository>(),
            );
            final searchHistorySuggestions = SearchHistorySuggestionsBloc(
              searchHistoryRepository: context.read<SearchHistoryRepository>(),
            );

            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: searchHistoryCubit),
                BlocProvider.value(
                  value: context.read<FavoriteTagBloc>()
                    ..add(const FavoriteTagFetched()),
                ),
                BlocProvider.value(
                  value: BlocProvider.of<ThemeBloc>(context),
                ),
                BlocProvider.value(value: searchHistorySuggestions),
                BlocProvider.value(value: relatedTagBloc),
              ],
              child: CustomContextMenuOverlay(
                child: childBuilder(context),
              ),
            );
          },
        ),
      );
    },
  );
}

void goToExplorePopularPage(BuildContext context) =>
    Navigator.of(context).push(ExplorePopularPage.routeOf(context));

void goToExploreHotPage(BuildContext context) =>
    Navigator.of(context).push(ExploreHotPage.routeOf(context));

void goToExploreMostViewedPage(BuildContext context) =>
    Navigator.of(context).push(ExploreMostViewedPage.routeOf(context));

void goToSavedSearchPage(BuildContext context, String? username) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => provideSavedSearchPageDependecies(
        context,
        page: const SavedSearchFeedPage(),
      ),
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (_) => provideSavedSearchPageDependecies(
        context,
        page: const SavedSearchFeedPage(),
      ),
    );
  }
}

Widget provideSavedSearchPageDependecies(
  BuildContext context, {
  required Widget page,
}) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (dcontext) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => SavedSearchFeedBloc(
                savedSearchBloc: dcontext.read<SavedSearchBloc>(),
              )..add(const SavedSearchFeedRefreshed()),
            ),
          ],
          child: CustomContextMenuOverlay(
            child: page,
          ),
        ),
      );
    },
  );
}

void goToSavedSearchEditPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) {
      return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
        builder: (_, state) {
          return DanbooruProvider.of(
            context,
            booru: state.booru!,
            builder: (dcontext) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: dcontext.read<SavedSearchBloc>()
                    ..add(const SavedSearchFetched()),
                ),
              ],
              child: const SavedSearchPage(),
            ),
          );
        },
      );
    },
  ));
}

void goToPoolPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) => DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PoolBloc(
                poolRepository: context.read<PoolRepository>(),
                postRepository: context.read<DanbooruPostRepository>(),
              )..add(const PoolRefreshed(
                  category: PoolCategory.series,
                  order: PoolOrder.latest,
                )),
            ),
          ],
          child: const PoolPage(),
        ),
      ),
    ),
  ));
}

void goToBlacklistedTagPage(BuildContext context) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => provideBlacklistedTagPageDependencies(
        context,
        page: const BlacklistedTagsPage(),
      ),
    ));
  }
  // else {
  // showDesktopDialogWindow(
  //   context,
  //   width: min(MediaQuery.of(context).size.width * 0.8, 700),
  //   height: min(MediaQuery.of(context).size.height * 0.8, 600),
  //   builder: (_) => provideBlacklistedTagPageDependencies(
  //     context,
  //     page: const BlacklistedTagsPageDesktop(),
  //   ),
  // );
  // }
}

Widget provideBlacklistedTagPageDependencies(
  BuildContext context, {
  required Widget page,
}) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (dcontext) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: dcontext.read<BlacklistedTagsBloc>()
                ..add(const BlacklistedTagRequested()),
            ),
          ],
          child: page,
        ),
      );
    },
  );
}

void goToBlacklistedTagsSearchPage(
  BuildContext context, {
  required void Function(List<TagSearchItem> tags) onSelectDone,
  List<String>? initialTags,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return TagStoreScope(
          builder: (tagStore) => DanbooruProvider.of(
            context,
            booru: state.booru!,
            builder: (dcontext) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => TagSearchBloc(
                    tagStore: tagStore,
                    tagInfo: dcontext.read<TagInfo>(),
                    autocompleteRepository:
                        dcontext.read<AutocompleteRepository>(),
                  ),
                ),
              ],
              child: BlacklistedTagsSearchPage(
                initialTags: initialTags,
                onSelectedDone: onSelectDone,
              ),
            ),
          ),
        );
      },
    ),
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
    builder: (_, useAppBar) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => CommentPage(
            useAppBar: useAppBar,
            postId: postId,
          ),
        );
      },
    ),
  );
}

void goToCommentCreatePage(
  BuildContext context, {
  required int postId,
  String? initialContent,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (context) => CommentCreatePage(
            postId: postId,
            initialContent: initialContent,
          ),
        );
      },
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
      builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
        builder: (_, state) {
          return DanbooruProvider.of(
            context,
            booru: state.booru!,
            builder: (context) => CommentUpdatePage(
              postId: postId,
              commentId: commentId,
              initialContent: commentBody,
            ),
          );
        },
      ),
      settings: const RouteSettings(
        name: RouterPageConstant.commentUpdate,
      ),
    ),
  );
}

void goToUserDetailsPage(
  BuildContext context, {
  required int uid,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
        builder: (_, state) {
          return DanbooruProvider.of(
            context,
            booru: state.booru!,
            builder: (dcontext) => BlocProvider(
              create: (_) => UserBloc(
                userRepository: dcontext.read<UserRepository>(),
                postRepository: dcontext.read<DanbooruPostRepository>(),
              )..add(UserFetched(uid: uid)),
              child: const UserDetailsPage(),
            ),
          );
        },
      ),
      settings: const RouteSettings(
        name: RouterPageConstant.commentUpdate,
      ),
    ),
  );
}

void goToPoolSearchPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => PoolBloc(
                  poolRepository: dcontext.read<PoolRepository>(),
                  postRepository: dcontext.read<DanbooruPostRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) => PoolSearchBloc(
                  poolRepository: dcontext.read<PoolRepository>(),
                ),
              ),
            ],
            child: const PoolSearchPage(),
          ),
        );
      },
    ),
    settings: const RouteSettings(
      name: RouterPageConstant.poolSearch,
    ),
  ));
}

void goToRelatedTagsPage(
  BuildContext context, {
  required RelatedTag relatedTag,
}) {
  final bloc = context.read<SearchBloc>();
  final page = BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (context, state) {
      final booru = state.booru ?? safebooru();

      return RelatedTagActionSheet(
        relatedTag: relatedTag,
        onOpenWiki: (tag) => launchWikiPage(
          booru.url,
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

void goToPostFavoritesDetails(BuildContext context, DanbooruPost post) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.postFavoriters,
    ),
    height: MediaQuery.of(context).size.height * 0.65,
    builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => BlocProvider(
            create: (_) => PostFavoriteBloc(
              favoritePostRepository: dcontext.read<FavoritePostRepository>(),
              userRepository: dcontext.read<UserRepository>(),
            )..add(PostFavoriteFetched(
                postId: post.id,
                refresh: true,
              )),
            child: FavoriterDetailsView(
              post: post,
            ),
          ),
        );
      },
    ),
  );
}

void goToPostVotesDetails(BuildContext context, DanbooruPost post) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.postVoters,
    ),
    height: MediaQuery.of(context).size.height * 0.65,
    builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => BlocProvider(
            create: (_) => PostVoteInfoBloc(
              postVoteRepository: dcontext.read<PostVoteRepository>(),
              userRepository: dcontext.read<UserRepository>(),
            )..add(PostVoteInfoFetched(
                postId: post.id,
                refresh: true,
              )),
            child: VoterDetailsView(
              post: post,
            ),
          ),
        );
      },
    ),
  );
}

void goToSavedSearchCreatePage(
  BuildContext context, {
  SavedSearch? initialValue,
}) {
  final bloc = context.read<SavedSearchBloc>();

  if (isMobilePlatform()) {
    showMaterialModalBottomSheet(
      context: context,
      settings: const RouteSettings(
        name: RouterPageConstant.savedSearchCreate,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (_) => EditSavedSearchSheet(
        initialValue: initialValue,
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
        name: RouterPageConstant.savedSearchCreate,
      ),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      pageBuilder: (context, _, __) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.background,
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

void goToSavedSearchPatchPage(
  BuildContext context,
  SavedSearch savedSearch,
  SavedSearchBloc bloc,
) {
  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.savedSearchPatch,
    ),
    backgroundColor: Theme.of(context).colorScheme.background,
    builder: (_) => EditSavedSearchSheet(
      title: 'saved_search.update_saved_search'.tr(),
      initialValue: savedSearch,
      onSubmit: (query, label) => bloc.add(SavedSearchUpdated(
        id: savedSearch.id,
        label: label,
        query: query,
        onUpdated: (data) => showSimpleSnackBar(
          context: context,
          duration: const Duration(
            seconds: 1,
          ),
          content: const Text(
            'saved_search.saved_search_updated',
          ).tr(),
        ),
      )),
    ),
  );
}

Future<Object?> goToFavoriteGroupCreatePage(
  BuildContext context,
  FavoriteGroupsBloc bloc, {
  bool enableManualPostInput = true,
}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (___, _, __) =>
        BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (context) => EditFavoriteGroupDialog(
            padding: isMobilePlatform() ? 0 : 8,
            title: 'favorite_groups.create_group'.tr(),
            enableManualDataInput: enableManualPostInput,
            onDone: (name, ids, isPrivate) => bloc.add(FavoriteGroupsCreated(
              name: name,
              initialIds: ids,
              isPrivate: isPrivate,
              onFailure: (message, translatable) => showSimpleSnackBar(
                context: context,
                content: translatable ? Text(message).tr() : Text(message),
              ),
            )),
          ),
        );
      },
    ),
  );
}

Future<Object?> goToFavoriteGroupEditPage(
  BuildContext context,
  FavoriteGroupsBloc bloc,
  FavoriteGroup group,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (dialogContext, _, __) =>
        BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => EditFavoriteGroupDialog(
            initialData: group,
            padding: isMobilePlatform() ? 0 : 8,
            title: 'favorite_groups.edit_group'.tr(),
            onDone: (name, ids, isPrivate) => bloc.add(FavoriteGroupsEdited(
              group: group,
              name: name,
              initialIds: ids,
              isPrivate: isPrivate,
              onFailure: (message) {
                showSimpleSnackBar(
                  context: context,
                  content: Text(message.toString()),
                );
              },
            )),
          ),
        );
      },
    ),
  );
}

void goToFavoriteGroupPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, dstate) {
        return DanbooruProvider.of(
          context,
          booru: dstate.booru!,
          builder: (dcontext) => BlocBuilder<CurrentUserBloc, CurrentUserState>(
            builder: (_, state) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => FavoriteGroupsBloc.of(
                      dcontext,
                      currentUser: state.user,
                    )..add(
                        const FavoriteGroupsRefreshed(includePreviews: true),
                      ),
                  ),
                ],
                child: const FavoriteGroupsPage(),
              );
            },
          ),
        );
      },
    );
  }));
}

void goToFavoriteGroupDetailsPage(
  BuildContext context,
  FavoriteGroup group,
  FavoriteGroupsBloc bloc,
) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: bloc),
            ],
            child: CustomContextMenuOverlay(
              child: FavoriteGroupDetailsPage(
                group: group,
                postIds: QueueList.from(group.postIds),
              ),
            ),
          ),
        );
      },
    );
  }));
}

Future<bool?> goToAddToFavoriteGroupSelectionPage(
  BuildContext context,
  List<Post> posts,
) {
  return showMaterialModalBottomSheet<bool>(
    context: context,
    duration: const Duration(milliseconds: 200),
    expand: true,
    builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => BlocBuilder<CurrentUserBloc, CurrentUserState>(
            builder: (_, state) {
              return BlocProvider(
                create: (_) => FavoriteGroupsBloc.of(
                  dcontext,
                  currentUser: state.user,
                )..add(const FavoriteGroupsRefreshed()),
                child: AddToFavoriteGroupPage(
                  posts: posts,
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

Future<bool?> goToAddToBlacklistPage(
  BuildContext context,
  DanbooruPost post,
) {
  final bloc = context.read<BlacklistedTagsBloc>();

  return showMaterialModalBottomSheet<bool>(
    context: navigatorKey.currentContext ?? context,
    duration: const Duration(milliseconds: 200),
    expand: true,
    builder: (dialogContext) => AddToBlacklistPage(
      tags: post.extractTags(),
      onAdded: (tag) => bloc.add(BlacklistedTagAdded(
        tag: tag.rawName,
        onFailure: (message) => showSimpleSnackBar(
          context: context,
          content: Text(message),
        ),
        onSuccess: (_) => showSimpleSnackBar(
          context: context,
          duration: const Duration(seconds: 2),
          content: const Text('Blacklisted tags updated'),
        ),
      )),
    ),
  );
}
