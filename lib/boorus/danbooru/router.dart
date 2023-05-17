// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/application/users.dart';
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
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/display.dart';
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
      builder: (_) => DanbooruArtistPage.of(context, artist),
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (_) => DanbooruArtistPage.of(context, artist),
    );
  }
}

void goToCharacterPage(BuildContext context, String tag) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CharacterPage.of(context, tag),
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (_) => CharacterPageDesktop.of(context, tag),
    );
  }
}

void goToFavoritesPage(BuildContext context, String? username) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => FavoritesPage.of(context, username: username!),
  ));
}

void goToPoolDetailPage(BuildContext context, Pool pool) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => PoolDetailPage.of(context, pool: pool),
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
}) =>
    Navigator.of(context).push(SearchPage.routeOf(context, tag: tag));

void goToExplorePopularPage(BuildContext context) =>
    Navigator.of(context).push(ExplorePopularPage.routeOf(context));

void goToExploreHotPage(BuildContext context) =>
    Navigator.of(context).push(ExploreHotPage.routeOf(context));

void goToExploreMostViewedPage(BuildContext context) =>
    Navigator.of(context).push(ExploreMostViewedPage.routeOf(context));

void goToSavedSearchPage(BuildContext context, String? username) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SavedSearchFeedPage.of(context),
    ));
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (_) => SavedSearchFeedPage.of(context),
    );
  }
}

void goToSavedSearchEditPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) {
      return DanbooruProvider.of(
        context,
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
  ));
}

void goToPoolPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider.of(
      context,
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
  return DanbooruProvider.of(
    context,
    builder: (dcontext) => page,
  );
}

void goToBlacklistedTagsSearchPage(
  BuildContext context, {
  required void Function(List<TagSearchItem> tags) onSelectDone,
  List<String>? initialTags,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider.of(
      context,
      builder: (dcontext) => BlacklistedTagsSearchPage(
        initialTags: initialTags,
        onSelectedDone: onSelectDone,
      ),
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
    builder: (_, useAppBar) => DanbooruProvider.of(
      context,
      builder: (dcontext) => CommentPage(
        useAppBar: useAppBar,
        postId: postId,
      ),
    ),
  );
}

void goToCommentCreatePage(
  BuildContext context, {
  required int postId,
  String? initialContent,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider.of(
      context,
      builder: (context) => CommentCreatePage(
        postId: postId,
        initialContent: initialContent,
      ),
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
      builder: (_) => DanbooruProvider.of(
        context,
        builder: (context) => CommentUpdatePage(
          postId: postId,
          commentId: commentId,
          initialContent: commentBody,
        ),
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
      builder: (_) => DanbooruProvider.of(
        context,
        builder: (dcontext) => BlocProvider(
          create: (_) => UserBloc(
            userRepository: dcontext.read<UserRepository>(),
            postRepository: dcontext.read<DanbooruPostRepository>(),
          )..add(UserFetched(uid: uid)),
          child: const UserDetailsPage(),
        ),
      ),
      settings: const RouteSettings(
        name: RouterPageConstant.commentUpdate,
      ),
    ),
  );
}

void goToPoolSearchPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider.of(
      context,
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
  final page = RelatedTagActionSheet(
    relatedTag: relatedTag,
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
  //FIXME: re enable this later
}

void goToPostVotesDetails(BuildContext context, DanbooruPost post) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.postVoters,
    ),
    height: MediaQuery.of(context).size.height * 0.65,
    builder: (_) => DanbooruProvider.of(
      context,
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
  BuildContext context, {
  bool enableManualPostInput = true,
}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (___, _, __) => DanbooruProvider.of(
      context,
      builder: (context) => EditFavoriteGroupDialog(
        padding: isMobilePlatform() ? 0 : 8,
        title: 'favorite_groups.create_group'.tr(),
        enableManualDataInput: enableManualPostInput,
      ),
    ),
  );
}

Future<Object?> goToFavoriteGroupEditPage(
  BuildContext context,
  FavoriteGroup group,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (dialogContext, _, __) => DanbooruProvider.of(
      context,
      builder: (dcontext) => EditFavoriteGroupDialog(
        initialData: group,
        padding: isMobilePlatform() ? 0 : 8,
        title: 'favorite_groups.edit_group'.tr(),
      ),
    ),
  );
}

void goToFavoriteGroupPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    return DanbooruProvider.of(
      context,
      builder: (dcontext) => const FavoriteGroupsPage(),
    );
  }));
}

void goToFavoriteGroupDetailsPage(
  BuildContext context,
  FavoriteGroup group,
) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    return DanbooruProvider.of(
      context,
      builder: (dcontext) => CustomContextMenuOverlay(
        child: FavoriteGroupDetailsPage(
          group: group,
          postIds: QueueList.from(group.postIds),
        ),
      ),
    );
  }));
}

Future<bool?> goToAddToFavoriteGroupSelectionPage(
  BuildContext context,
  List<DanbooruPost> posts,
) {
  return showMaterialModalBottomSheet<bool>(
    context: context,
    duration: const Duration(milliseconds: 200),
    expand: true,
    builder: (_) => DanbooruProvider.of(
      context,
      builder: (dcontext) => AddToFavoriteGroupPage(
        posts: posts,
      ),
    ),
  );
}

Future<bool?> goToAddToBlacklistPage(
  BuildContext context,
  DanbooruPost post,
) {
  return showMaterialModalBottomSheet<bool>(
    context: navigatorKey.currentContext ?? context,
    duration: const Duration(milliseconds: 200),
    expand: true,
    builder: (dialogContext) => AddToBlacklistPage(
      tags: post.extractTags(),
    ),
  );
}
