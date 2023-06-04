// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/features/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/pages/artists/danbooru_artist_page.dart';
import 'package:boorusama/boorus/danbooru/pages/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/pages/blacklisted_tags/blacklisted_tags_search_page.dart';
import 'package:boorusama/boorus/danbooru/pages/characters/character_page.dart';
import 'package:boorusama/boorus/danbooru/pages/characters/character_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/pages/comment/comment_create_page.dart';
import 'package:boorusama/boorus/danbooru/pages/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/pages/comment/comment_update_page.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_hot_page.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_most_viewed_page.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_popular_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/add_to_favorite_group_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/create_favorite_group_dialog.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorite_group_details_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_page.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/pages/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/saved_search_feed_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/saved_search_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/boorus/danbooru/pages/search/result/related_tag_action_sheet.dart';
import 'package:boorusama/boorus/danbooru/pages/search/search_page.dart';
import 'package:boorusama/boorus/danbooru/pages/users/user_details_page.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/blacklists.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/i18n.dart';
import 'features/posts/models.dart';
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
      return DanbooruProvider(
        builder: (_) => const SavedSearchPage(),
      );
    },
  ));
}

void goToPoolPage(BuildContext context, WidgetRef ref) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider(
      builder: (_) => const PoolPage(),
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
}) =>
    DanbooruProvider(builder: (_) => page);

void goToBlacklistedTagsSearchPage(
  BuildContext context, {
  required void Function(List<TagSearchItem> tags) onSelectDone,
  List<String>? initialTags,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider(
      builder: (_) => BlacklistedTagsSearchPage(
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
    builder: (_, useAppBar) => DanbooruProvider(
      builder: (_) => CommentPage(
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
    builder: (_) => DanbooruProvider(
      builder: (_) => CommentCreatePage(
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
      builder: (_) => DanbooruProvider(
        builder: (_) => CommentUpdatePage(
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
  WidgetRef ref,
  BuildContext context, {
  required int uid,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DanbooruProvider(
        builder: (_) => UserDetailsPage(
          uid: uid,
        ),
      ),
      settings: const RouteSettings(
        name: RouterPageConstant.commentUpdate,
      ),
    ),
  );
}

void goToPoolSearchPage(BuildContext context, WidgetRef ref) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider(
      builder: (_) => const PoolSearchPage(),
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
  //FIXME: re enable this later
}

void goToSavedSearchCreatePage(
  WidgetRef ref,
  BuildContext context, {
  SavedSearch? initialValue,
}) {
  if (isMobilePlatform()) {
    showMaterialModalBottomSheet(
      context: context,
      settings: const RouteSettings(
        name: RouterPageConstant.savedSearchCreate,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (_) => EditSavedSearchSheet(
        initialValue: initialValue,
        onSubmit: (query, label) =>
            ref.read(danbooruSavedSearchesProvider.notifier).create(
                  query: query,
                  label: label,
                  onCreated: (data) => showSimpleSnackBar(
                    context: context,
                    duration: const Duration(seconds: 1),
                    content: const Text('saved_search.saved_search_added').tr(),
                  ),
                ),
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
              onSubmit: (query, label) =>
                  ref.read(danbooruSavedSearchesProvider.notifier).create(
                        query: query,
                        label: label,
                        onCreated: (data) => showSimpleSnackBar(
                          context: context,
                          duration: const Duration(seconds: 1),
                          content: const Text('saved_search.saved_search_added')
                              .tr(),
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}

void goToSavedSearchPatchPage(
  WidgetRef ref,
  BuildContext context,
  SavedSearch savedSearch,
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
      onSubmit: (query, label) =>
          ref.read(danbooruSavedSearchesProvider.notifier).update(
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
              ),
    ),
  );
}

Future<Object?> goToFavoriteGroupCreatePage(
  BuildContext context, {
  bool enableManualPostInput = true,
}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (___, _, __) => DanbooruProvider(
      builder: (_) => EditFavoriteGroupDialog(
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
    pageBuilder: (dialogContext, _, __) => DanbooruProvider(
      builder: (_) => EditFavoriteGroupDialog(
        initialData: group,
        padding: isMobilePlatform() ? 0 : 8,
        title: 'favorite_groups.edit_group'.tr(),
      ),
    ),
  );
}

void goToFavoriteGroupPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider(
      builder: (_) => const FavoriteGroupsPage(),
    ),
  ));
}

void goToFavoriteGroupDetailsPage(
  BuildContext context,
  FavoriteGroup group,
) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => DanbooruProvider(
      builder: (_) => CustomContextMenuOverlay(
        child: FavoriteGroupDetailsPage(
          group: group,
          postIds: QueueList.from(group.postIds),
        ),
      ),
    ),
  ));
}

Future<bool?> goToAddToFavoriteGroupSelectionPage(
  BuildContext context,
  List<DanbooruPost> posts,
) {
  return showMaterialModalBottomSheet<bool>(
    context: context,
    duration: const Duration(milliseconds: 200),
    expand: true,
    builder: (_) => DanbooruProvider(
      builder: (_) => AddToFavoriteGroupPage(
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
