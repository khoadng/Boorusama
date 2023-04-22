// Dart imports:
import 'dart:math';

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
import 'package:boorusama/boorus/danbooru/application/explores.dart';
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
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/ui/features/artists/artist_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/characters/character_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/characters/character_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_create_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_update_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/add_to_favorite_group_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/create_favorite_group_dialog.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorite_group_details_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/parent_child_post_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/add_to_blacklist_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/saved_search_feed_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/saved_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/result/related_tag_action_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/users/user_details_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'router_page_constant.dart';

void goToArtistPage(BuildContext context, String artist) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => provideArtistPageDependencies(
        context,
        artist: artist,
        page: ArtistPage(
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
        page: ArtistPage(
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
              BlocProvider(
                create: (_) => DanbooruArtistCharacterPostCubit.of(
                  dcontext,
                  extra: DanbooruArtistChararacterExtra(
                    category: TagFilterCategory.newest,
                    tag: artist,
                  ),
                )..refresh(),
              ),
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
              BlocProvider(
                create: (_) => DanbooruArtistCharacterPostCubit.of(
                  dcontext,
                  extra: DanbooruArtistChararacterExtra(
                    category: TagFilterCategory.newest,
                    tag: character,
                  ),
                )..refresh(),
              ),
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
                BlocProvider(
                  create: (_) => DanbooruPostCubit.of(
                    dcontext,
                    extra: DanbooruPostExtra(tag: 'pool:${pool.id}'),
                  )..refresh(),
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
    child: BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => DanbooruPostCubit.of(
                  dcontext,
                  extra: DanbooruPostExtra(tag: tagQueryForDataFetching),
                )..refresh(),
              ),
            ],
            child: CustomContextMenuOverlay(
              child: ParentChildPostPage(parentPostId: parentId),
            ),
          ),
        );
      },
    ),
  ));
}

Future<void> goToDetailPage({
  required BuildContext context,
  required List<DanbooruPostData> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
  bool hero = false,
  // PostBloc? postBloc,
}) {
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

  final page = providePostDetailPageDependencies(
    context,
    posts,
    initialIndex,
    tags,
    scrollController,
    PostDetailPage(
      intitialIndex: initialIndex,
      posts: posts,
      onPageChanged: (page) {
        scrollController?.scrollToIndex(page);
      },
    ),
  );

  return Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
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

Widget providePostDetailPageDependencies(
  BuildContext context,
  List<DanbooruPostData> posts,
  int initialIndex,
  List<PostDetailTag> tags,
  // PostBloc? postBloc,
  AutoScrollController? scrollController,
  Widget child,
) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (context) {
          return BlocSelector<SettingsCubit, SettingsState, Settings>(
            selector: (state) => state.settings,
            builder: (_, settings) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => SliverPostGridBloc()),
                  BlocProvider.value(
                    value: context.read<AuthenticationCubit>(),
                  ),
                  BlocProvider.value(value: context.read<ThemeBloc>()),
                  BlocProvider(
                    create: (context) => PostDetailBloc(
                      booruUserIdentityProvider:
                          context.read<BooruUserIdentityProvider>(),
                      noteRepository: context.read<NoteRepository>(),
                      defaultDetailsStyle: settings.detailsDisplay,
                      posts: posts,
                      initialIndex: initialIndex,
                      postRepository: context.read<DanbooruPostRepository>(),
                      favoritePostRepository:
                          context.read<FavoritePostRepository>(),
                      currentBooruConfigRepository:
                          context.read<CurrentBooruConfigRepository>(),
                      postVoteRepository: context.read<PostVoteRepository>(),
                      tags: tags,
                      onPostChanged: (post) {
                        // if (postBloc != null && !postBloc.isClosed) {
                        //   postBloc.add(PostUpdated(post: post));
                        // }
                      },
                      tagCache: {},
                    ),
                  ),
                ],
                child: RepositoryProvider.value(
                  value: context.read<TagRepository>(),
                  child: Builder(
                    builder: (context) =>
                        BlocListener<SliverPostGridBloc, SliverPostGridState>(
                      listenWhen: (previous, current) =>
                          previous.nextIndex != current.nextIndex,
                      listener: (context, state) {
                        if (scrollController == null) return;
                        scrollController.scrollToIndex(
                          state.nextIndex,
                          duration: const Duration(milliseconds: 200),
                        );
                      },
                      child: child,
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
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
        (context, settings) => SearchPage(
          pagination: settings.contentOrganizationCategory ==
              ContentOrganizationCategory.pagination,
          autoFocusSearchBar: settings.autoFocusSearchBar,
          metatags: context.read<TagInfo>().metatags,
          metatagHighlightColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (_) => provideSearchPageDependencies(
        context,
        tag,
        (context, settings) => SearchPageDesktop(
          pagination: settings.contentOrganizationCategory ==
              ContentOrganizationCategory.pagination,
          metatags: context.read<TagInfo>().metatags,
          metatagHighlightColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

Widget provideSearchPageDependencies(
  BuildContext context,
  String? tag,
  Widget Function(BuildContext context, Settings settings) childBuilder,
) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (context) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (_, settingsState) {
              final tagSearchBloc = TagSearchBloc(
                tagInfo: context.read<TagInfo>(),
                autocompleteRepository: context.read<AutocompleteRepository>(),
              );

              final postCubit = DanbooruPostCubit.of(
                context,
                extra: DanbooruPostExtra(
                  tag: tagSearchBloc.state.selectedTags.join(' '),
                  limit: settingsState.settings.postsPerPage,
                ),
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
                  BlocProvider.value(value: postCubit),
                  BlocProvider.value(
                    value: BlocProvider.of<ThemeBloc>(context),
                  ),
                  BlocProvider.value(value: searchHistorySuggestions),
                  BlocProvider<SearchBloc>(
                    create: (context) => DanbooruSearchBloc(
                      initial: DisplayState.options,
                      metatags: context.read<TagInfo>().metatags,
                      tagSearchBloc: tagSearchBloc,
                      searchHistoryBloc: searchHistoryCubit,
                      relatedTagBloc: relatedTagBloc,
                      searchHistorySuggestionsBloc: searchHistorySuggestions,
                      postCubit: postCubit,
                      postCountRepository: context.read<PostCountRepository>(),
                      initialQuery: tag,
                      booruType: state.booru!.booruType,
                    ),
                  ),
                  BlocProvider.value(value: relatedTagBloc),
                ],
                child: CustomContextMenuOverlay(
                  child: childBuilder(context, settingsState.settings),
                ),
              );
            },
          );
        },
      );
    },
  );
}

void goToExploreDetailPage(
  BuildContext context,
  DateTime? date,
  String title,
  ExploreCategory category,
) {
  final a = () {
    switch (category) {
      case ExploreCategory.popular:
        return context.read<DanbooruPopularExplorePostCubit>();
      case ExploreCategory.mostViewed:
        return context.read<DanbooruMostViewedExplorePostCubit>();
      case ExploreCategory.hot:
        return context.read<DanbooruHotExplorePostCubit>();
    }
  }();

  final b = () {
    switch (category) {
      case ExploreCategory.popular:
        return context.read<ExplorePopularDetailBloc>();
      case ExploreCategory.mostViewed:
        return context.read<ExploreMostViewedDetailBloc>();
      case ExploreCategory.hot:
        return context.read<ExploreHotDetailBloc>();
    }
  }();

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
        builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dcontext) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: b),
                    BlocProvider(
                      create: (_) => a,
                    ),
                  ],
                  child: CustomContextMenuOverlay(
                    child: ExploreDetailPage(
                      title: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      category: category,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) {
        final exploreDetailsBloc = ExploreDetailBloc(
          initialDate: date,
          category: category,
        );

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: exploreDetailsBloc),
            BlocProvider(
              create: (_) => DanbooruExplorePostCubit.of(
                context,
                exploreDetailBloc: exploreDetailsBloc,
              )..refresh(),
            ),
          ],
          child: CustomContextMenuOverlay(
            child: ExploreDetailPage(
              title: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              category: category,
            ),
          ),
        );
      },
    );
  }
}

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
              create: (_) => DanbooruPostCubit.of(
                dcontext,
                extra: DanbooruPostExtra(tag: SavedSearch.all().toQuery()),
              )..refresh(),
            ),
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

void goToBlacklistedTagPage(BuildContext context) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => provideBlacklistedTagPageDependencies(
        context,
        page: const BlacklistedTagsPage(),
      ),
    ));
  } else {
    showDesktopDialogWindow(
      context,
      width: min(MediaQuery.of(context).size.width * 0.8, 700),
      height: min(MediaQuery.of(context).size.height * 0.8, 600),
      builder: (_) => provideBlacklistedTagPageDependencies(
        context,
        page: const BlacklistedTagsPageDesktop(),
      ),
    );
  }
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
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => TagSearchBloc(
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
              BlocProvider(
                create: (_) => DanbooruFavoriteGroupPostCubit.of(
                  dcontext,
                  ids: () => group.postIds,
                )..refresh(),
              ),
              BlocProvider.value(value: bloc),
            ],
            child: CustomContextMenuOverlay(
              child: FavoriteGroupDetailsPage(
                group: group,
                postIds: QueueList.from(group.postIds.skip(60)),
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
