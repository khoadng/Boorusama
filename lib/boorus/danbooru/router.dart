// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/core/pages/blacklists/add_to_blacklist_page.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/pages/artists/danbooru_artist_page.dart';
import 'package:boorusama/boorus/danbooru/pages/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/pages/characters/danbooru_character_page.dart';
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
import 'package:boorusama/boorus/danbooru/pages/forums/danbooru_forum_page.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_detail_page.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_page.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_search_page.dart';
import 'package:boorusama/boorus/danbooru/pages/post_details/danbooru_post_details_desktop_page.dart';
import 'package:boorusama/boorus/danbooru/pages/post_details/danbooru_post_details_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/saved_search_feed_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/saved_search_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/boorus/danbooru/pages/search/danbooru_search_page.dart';
import 'package:boorusama/boorus/danbooru/pages/search/result/related_tag_action_sheet.dart';
import 'package:boorusama/boorus/danbooru/pages/users/user_details_page.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'router_page_constant.dart';

void goToArtistPage(BuildContext context, String artist) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => DanbooruArtistPage.of(context, artist),
  ));
}

void goToCharacterPage(BuildContext context, String tag) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => DanbooruCharacterPage.of(context, tag),
  ));
}

void goToFavoritesPage(BuildContext context, String? username) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => FavoritesPage.of(context, username: username!),
  ));
}

void goToPoolDetailPage(BuildContext context, Pool pool) {
  context.navigator.push(MaterialPageRoute(
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
  if (isMobilePlatform() && context.orientation.isPortrait) {
    return context.navigator.push(DanbooruPostDetailsPage.routeOf(
      context,
      posts: posts,
      scrollController: scrollController,
      initialIndex: initialIndex,
      hero: hero,
    ));
  } else {
    return showDesktopFullScreenWindow(
      context,
      builder: (_) => DanbooruPostDetailsDesktopPage(
        initialIndex: initialIndex,
        posts: posts,
        onExit: (index) {
          scrollController?.scrollToIndex(index);
        },
      ),
    );
  }
}

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) =>
    context.navigator.push(DanbooruSearchPage.routeOf(context, tag: tag));

void goToExplorePopularPage(BuildContext context) =>
    context.navigator.push(ExplorePopularPage.routeOf(context));

void goToExploreHotPage(BuildContext context) =>
    context.navigator.push(ExploreHotPage.routeOf(context));

void goToExploreMostViewedPage(BuildContext context) =>
    context.navigator.push(ExploreMostViewedPage.routeOf(context));

void goToSavedSearchPage(BuildContext context, String? username) {
  if (isMobilePlatform()) {
    context.navigator.push(MaterialPageRoute(
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
  context.navigator.push(MaterialPageRoute(
    builder: (_) {
      return const SavedSearchPage();
    },
  ));
}

void goToPoolPage(BuildContext context, WidgetRef ref) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => const PoolPage(),
  ));
}

void goToBlacklistedTagPage(BuildContext context) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => const BlacklistedTagsPage(),
  ));
}

void goToCommentPage(BuildContext context, int postId) {
  showCommentPage(
    context,
    postId: postId,
    settings: const RouteSettings(
      name: RouterPageConstant.comment,
    ),
    builder: (_, useAppBar) => CommentPage(
      useAppBar: useAppBar,
      postId: postId,
    ),
  );
}

void goToCommentCreatePage(
  BuildContext context, {
  required int postId,
  String? initialContent,
}) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => CommentCreatePage(
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
  context.navigator.push(
    MaterialPageRoute(
      builder: (_) => CommentUpdatePage(
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
  WidgetRef ref,
  BuildContext context, {
  required int uid,
  required String username,
}) {
  context.navigator.push(
    MaterialPageRoute(
      builder: (_) => UserDetailsPage(
        uid: uid,
        username: username,
      ),
    ),
  );
}

void goToPoolSearchPage(BuildContext context, WidgetRef ref) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => const PoolSearchPage(),
    settings: const RouteSettings(
      name: RouterPageConstant.poolSearch,
    ),
  ));
}

void goToRelatedTagsPage(
  BuildContext context, {
  required RelatedTag relatedTag,
  required void Function(RelatedTagItem tag) onSelected,
}) {
  final page = RelatedTagActionSheet(
    relatedTag: relatedTag,
    onSelected: onSelected,
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
      backgroundColor: context.colorScheme.background,
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
          backgroundColor: context.colorScheme.background,
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
    backgroundColor: context.colorScheme.background,
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
    pageBuilder: (___, _, __) => EditFavoriteGroupDialog(
      padding: isMobilePlatform() ? 0 : 8,
      title: 'favorite_groups.create_group'.tr(),
      enableManualDataInput: enableManualPostInput,
    ),
  );
}

Future<Object?> goToFavoriteGroupEditPage(
  BuildContext context,
  FavoriteGroup group,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (dialogContext, _, __) => EditFavoriteGroupDialog(
      initialData: group,
      padding: isMobilePlatform() ? 0 : 8,
      title: 'favorite_groups.edit_group'.tr(),
    ),
  );
}

void goToFavoriteGroupPage(BuildContext context) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => const FavoriteGroupsPage(),
  ));
}

void goToFavoriteGroupDetailsPage(
  BuildContext context,
  FavoriteGroup group,
) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => CustomContextMenuOverlay(
      child: FavoriteGroupDetailsPage(
        group: group,
        postIds: QueueList.from(group.postIds),
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
    builder: (_) => AddToFavoriteGroupPage(
      posts: posts,
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

void goToForumPage(BuildContext context) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => const DanbooruForumPage(),
  ));
}
