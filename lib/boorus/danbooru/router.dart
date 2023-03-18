// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_feed_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/tag/trending_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/user/current_user_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/user/user_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki_bloc.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/boorus/danbooru/ui/features/artists/artist_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/characters/character_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/characters/character_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_create_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_update_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/add_to_favorite_group_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/create_favorite_group_dialog.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorite_group_details_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/parent_child_post_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/post_detail_page_provider.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/add_to_blacklist_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/saved_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/full_history_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/landing/favorite_tags/import_favorite_tag_dialog.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/result/related_tag_action_sheet.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_page_provider.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/appearance_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/download_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/general_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/language_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/performance_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/privacy_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/search_settings_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/settings_page.dart';
import 'package:boorusama/boorus/danbooru/ui/features/settings/settings_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/features/users/user_details_page.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/domain/posts/post.dart' as core;
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'package:boorusama/core/ui/info_container.dart';
import 'package:boorusama/core/ui/original_image_page.dart';
import 'package:boorusama/core/ui/widgets/parallax_slide_in_page_route.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'router_page_constant.dart';
import 'ui/features/post_detail/post_detail_page.dart';
import 'ui/features/post_detail/post_detail_page_desktop.dart';
import 'ui/features/saved_search/saved_search_feed_page.dart';

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
                create: (_) => PostBloc.of(dcontext)
                  ..add(PostRefreshed(
                    tag: artist,
                    fetcher: SearchedPostFetcher.fromTags(artist),
                  )),
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
                create: (_) => PostBloc.of(dcontext)
                  ..add(PostRefreshed(
                    tag: character,
                    fetcher: SearchedPostFetcher.fromTags(character),
                  )),
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

void goToBulkDownloadPage(
  BuildContext context,
  List<String>? tags,
) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) {
      return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
        builder: (_, state) {
          return DanbooruProvider.of(
            context,
            booru: state.booru!,
            builder: (dcontext) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => BulkImageDownloadBloc(
                    permissionChecker: () => Permission.storage.status,
                    permissionRequester: () => Permission.storage.request(),
                    bulkPostDownloadBloc: BulkPostDownloadBloc(
                      downloader: dcontext.read<BulkDownloader<Post>>(),
                      postCountRepository: dcontext.read<PostCountRepository>(),
                      postRepository: dcontext.read<PostRepository>(),
                      errorTranslator: getErrorMessage,
                      onDownloadDone: (path) =>
                          MediaScanner.loadMedia(path: path),
                    ),
                  )..add(BulkImageDownloadTagsAdded(tags: tags)),
                ),
              ],
              child: const BulkDownloadPage(),
            ),
          );
        },
      );
    },
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
                  create: (_) => PostBloc.of(dcontext)
                    ..add(
                      PostRefreshed(
                        fetcher: PoolPostFetcher(
                          postIds: pool.postIds.reversed.take(20).toList(),
                        ),
                      ),
                    ),
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
                create: (_) => PostBloc.of(dcontext)
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
        );
      },
    ),
  ));
}

void goToHomePage(
  BuildContext context, {
  bool replace = false,
}) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void goToDetailPage({
  required BuildContext context,
  required List<PostData> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
  PostBloc? postBloc,
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

  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dContext) {
                final authCubit = dContext.read<AuthenticationCubit>();
                final tagRepo = dContext.read<TagRepository>();
                final noteRepo = dContext.read<NoteRepository>();
                final postVoteRepo = dContext.read<PostVoteRepository>();
                final favRepo = dContext.read<FavoritePostRepository>();
                final postRepo = dContext.read<PostRepository>();
                final tagBloc = dContext.read<TagBloc>();
                final themeBloc = dContext.read<ThemeBloc>();
                final accountRepo = dContext.read<AccountRepository>();

                return PostDetailPageProvider(
                  authCubit: authCubit,
                  tagBloc: tagBloc,
                  themeBloc: themeBloc,
                  noteRepo: noteRepo,
                  postRepo: postRepo,
                  favRepo: favRepo,
                  accountRepo: accountRepo,
                  postVoteRepo: postVoteRepo,
                  tags: tags,
                  tagRepo: tagRepo,
                  initialIndex: initialIndex,
                  postBloc: postBloc,
                  posts: posts,
                  scrollController: scrollController,
                  builder: (_, __) => PostDetailPage(
                    intitialIndex: initialIndex,
                    posts: posts,
                  ),
                );
              },
            );
          },
        );
      },
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dContext) {
                final authCubit = dContext.read<AuthenticationCubit>();
                final tagRepo = dContext.read<TagRepository>();
                final noteRepo = dContext.read<NoteRepository>();
                final postVoteRepo = dContext.read<PostVoteRepository>();
                final favRepo = dContext.read<FavoritePostRepository>();
                final postRepo = dContext.read<PostRepository>();
                final tagBloc = dContext.read<TagBloc>();
                final themeBloc = dContext.read<ThemeBloc>();
                final accountRepo = dContext.read<AccountRepository>();

                return PostDetailPageProvider(
                  authCubit: authCubit,
                  tagBloc: tagBloc,
                  themeBloc: themeBloc,
                  noteRepo: noteRepo,
                  postRepo: postRepo,
                  favRepo: favRepo,
                  accountRepo: accountRepo,
                  postVoteRepo: postVoteRepo,
                  tags: tags,
                  tagRepo: tagRepo,
                  initialIndex: initialIndex,
                  postBloc: postBloc,
                  posts: posts,
                  scrollController: scrollController,
                  builder: (_, __) => PostDetailPageDesktop(
                    intitialIndex: initialIndex,
                    posts: posts,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dContext) {
                final tagInfo = dContext.read<TagInfo>();
                final autocompleteRepo =
                    dContext.read<AutocompleteRepository>();
                final postRepo = dContext.read<PostRepository>();
                final blacklistRepo =
                    dContext.read<BlacklistedTagsRepository>();
                final favRepo = dContext.read<FavoritePostRepository>();
                final accountRepo = dContext.read<AccountRepository>();
                final postVoteRepo = dContext.read<PostVoteRepository>();
                final poolRepo = dContext.read<PoolRepository>();
                final previewPreloader = dContext.read<PostPreviewPreloader>();
                final searchHistoryRepo =
                    dContext.read<SearchHistoryRepository>();
                final relatedTagRepo = dContext.read<RelatedTagRepository>();
                final favTagBloc = dContext.read<FavoriteTagBloc>();
                final themeBloc = dContext.read<ThemeBloc>();
                final postCountRepo = dContext.read<PostCountRepository>();
                final trendingTagCubit = dContext.read<TrendingTagCubit>();
                final authenticationCubit =
                    dContext.read<AuthenticationCubit>();

                return SearchPageProvider(
                  authenticationCubit: authenticationCubit,
                  trendingTagCubit: trendingTagCubit,
                  tagInfo: tagInfo,
                  autocompleteRepo: autocompleteRepo,
                  postRepo: postRepo,
                  blacklistRepo: blacklistRepo,
                  favRepo: favRepo,
                  accountRepo: accountRepo,
                  postVoteRepo: postVoteRepo,
                  poolRepo: poolRepo,
                  previewPreloader: previewPreloader,
                  searchHistoryRepo: searchHistoryRepo,
                  relatedTagRepo: relatedTagRepo,
                  favTagBloc: favTagBloc,
                  themeBloc: themeBloc,
                  postCountRepo: postCountRepo,
                  initialQuery: tag,
                  builder: (context, settings) => SearchPage(
                    autoFocusSearchBar: settings.autoFocusSearchBar,
                    metatags: tagInfo.metatags,
                    metatagHighlightColor:
                        Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            );
          },
        );
      },
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (_) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (context, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dContext) {
                final tagInfo = dContext.read<TagInfo>();
                final autocompleteRepo =
                    dContext.read<AutocompleteRepository>();
                final postRepo = dContext.read<PostRepository>();
                final blacklistRepo =
                    dContext.read<BlacklistedTagsRepository>();
                final favRepo = dContext.read<FavoritePostRepository>();
                final accountRepo = dContext.read<AccountRepository>();
                final postVoteRepo = dContext.read<PostVoteRepository>();
                final poolRepo = dContext.read<PoolRepository>();
                final previewPreloader = dContext.read<PostPreviewPreloader>();
                final searchHistoryRepo =
                    dContext.read<SearchHistoryRepository>();
                final relatedTagRepo = dContext.read<RelatedTagRepository>();
                final favTagBloc = dContext.read<FavoriteTagBloc>();
                final themeBloc = dContext.read<ThemeBloc>();
                final postCountRepo = dContext.read<PostCountRepository>();
                final trendingTagCubit = dContext.read<TrendingTagCubit>();
                final authenticationCubit =
                    dContext.read<AuthenticationCubit>();

                return SearchPageProvider(
                  authenticationCubit: authenticationCubit,
                  trendingTagCubit: trendingTagCubit,
                  tagInfo: tagInfo,
                  autocompleteRepo: autocompleteRepo,
                  postRepo: postRepo,
                  blacklistRepo: blacklistRepo,
                  favRepo: favRepo,
                  accountRepo: accountRepo,
                  postVoteRepo: postVoteRepo,
                  poolRepo: poolRepo,
                  previewPreloader: previewPreloader,
                  searchHistoryRepo: searchHistoryRepo,
                  relatedTagRepo: relatedTagRepo,
                  favTagBloc: favTagBloc,
                  themeBloc: themeBloc,
                  postCountRepo: postCountRepo,
                  initialQuery: tag,
                  builder: (context, settings) => SearchPageDesktop(
                    metatags: tagInfo.metatags,
                    metatagHighlightColor:
                        Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

void goToSettingPage(BuildContext context) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ));
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
        builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dcontext) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => ExploreDetailBloc(initialDate: date),
                  ),
                  BlocProvider(
                    create: (_) => PostBloc.of(dcontext)
                      ..add(
                        PostRefreshed(
                          fetcher: categoryToFetcher(
                            category,
                            date ?? DateTime.now(),
                            TimeScale.day,
                            dcontext,
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
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    category: category,
                  ),
                ),
              ),
            );
          },
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
                  .titleLarge!
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
              create: (_) => PostBloc.of(dcontext),
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

void goToSettingsPerformance(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const PerformancePage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsPerformance,
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
                postRepository: dcontext.read<PostRepository>(),
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
                  postRepository: dcontext.read<PostRepository>(),
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
    builder: (_, isMobile) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dcontext) => isMobile
              ? SimpleTagSearchView(
                  onSubmitted: onSubmitted,
                  ensureValidTag: ensureValidTag,
                  floatingActionButton: floatingActionButton != null
                      ? (text) => floatingActionButton.call(text)
                      : null,
                  onSelected: onSelected,
                )
              : SimpleTagSearchView(
                  onSubmitted: onSubmitted,
                  backButton: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  ensureValidTag: ensureValidTag,
                  onSelected: onSelected,
                ),
        );
      },
    ),
  );
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

void goToPostVotesDetails(BuildContext context, Post post) {
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

Future<Object?> goToFavoriteGroupCreatePage(
  BuildContext context,
  FavoriteGroupsBloc bloc, {
  bool enableManualPostInput = true,
}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, _, __) => EditFavoriteGroupDialog(
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
}

Future<Object?> goToFavoriteGroupEditPage(
  BuildContext context,
  FavoriteGroupsBloc bloc,
  FavoriteGroup group,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (dialogContext, _, __) => EditFavoriteGroupDialog(
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
}

void goToImagePreviewPage(BuildContext context, core.Post post) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.postQuickPreview,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => QuickPreviewImage(
      child: BooruImage(
        placeholderUrl: post.thumbnailImageUrl,
        aspectRatio: post.aspectRatio,
        imageUrl: post.sampleImageUrl,
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
    builder: (_) => BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('search.history.history').tr(),
            actions: [
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text('Are you sure?').tr(),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onBackground,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('generic.action.cancel').tr(),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onClear();
                        },
                        child: const Text('generic.action.ok').tr(),
                      ),
                    ],
                  ),
                ),
                child: const Text('search.history.clear').tr(),
              ),
            ],
          ),
          body: FullHistoryView(
            scrollController: ModalScrollController.of(context),
            onHistoryTap: (value) => onTap(value),
            onHistoryRemoved: (value) => onRemove(value),
            onHistoryFiltered: (value) =>
                bloc.add(SearchHistoryFiltered(value)),
            histories: state.filteredhistories,
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
                create: (_) => PostBloc.of(dcontext)
                  ..add(PostRefreshed(
                    fetcher: FavoriteGroupPostFetcher(
                      ids: group.postIds.take(60).toList(),
                    ),
                  )),
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
  List<core.Post> posts,
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
  Post post,
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
