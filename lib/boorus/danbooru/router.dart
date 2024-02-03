// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/pages/show_tag_list_page.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'pages/add_to_favorite_group_page.dart';
import 'pages/blacklisted_tags_page.dart';
import 'pages/comment_create_page.dart';
import 'pages/comment_update_page.dart';
import 'pages/danbooru_artist_search_page.dart';
import 'pages/danbooru_character_page.dart';
import 'pages/danbooru_dmail_page.dart';
import 'pages/danbooru_forum_page.dart';
import 'pages/danbooru_post_versions_page.dart';
import 'pages/explore_hot_page.dart';
import 'pages/explore_most_viewed_page.dart';
import 'pages/explore_popular_page.dart';
import 'pages/favorite_group_details_page.dart';
import 'pages/favorite_groups_page.dart';
import 'pages/pool_detail_page.dart';
import 'pages/pool_page.dart';
import 'pages/pool_search_page.dart';
import 'pages/saved_search_feed_page.dart';
import 'pages/saved_search_page.dart';
import 'pages/tag_edit_page.dart';
import 'pages/user_details_page.dart';
import 'pages/widgets/favorites/create_favorite_group_dialog.dart';
import 'pages/widgets/saved_searches/edit_saved_search_sheet.dart';
import 'pages/widgets/search/related_tag_action_sheet.dart';
import 'router_page_constant.dart';

void goToCharacterPage(BuildContext context, String tag) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => DanbooruCharacterPage.of(context, tag),
  ));
}

void goToPoolDetailPage(BuildContext context, Pool pool) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => PoolDetailPage.of(context, pool: pool),
  ));
}

void goToPostVersionPage(BuildContext context, DanbooruPost post) {
  if (isMobilePlatform()) {
    showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 250),
      builder: (_) => DanbooruPostVersionsPage(
        postId: post.id,
        previewUrl: post.url720x720,
      ),
    );
  } else {
    showSideSheetFromRight(
      context: context,
      width: min(context.screenWidth * 0.35, 500),
      body: DanbooruPostVersionsPage(
        postId: post.id,
        previewUrl: post.url720x720,
      ),
    );
  }
}

void goToExplorePopularPage(BuildContext context) {
  if (isMobilePlatform()) {
    context.navigator.push(CupertinoPageRoute(
      settings: const RouteSettings(
        name: RouterPageConstant.explorePopular,
      ),
      builder: (_) => ExplorePopularPage.routeOf(context),
    ));
  } else {
    showDesktopWindow(
      context,
      builder: (_) => ExplorePopularPage.routeOf(context),
    );
  }
}

void goToExploreHotPage(BuildContext context) {
  if (isMobilePlatform()) {
    context.navigator.push(CupertinoPageRoute(
      settings: const RouteSettings(
        name: RouterPageConstant.exploreHot,
      ),
      builder: (_) => ExploreHotPage.routeOf(context),
    ));
  } else {
    showDesktopWindow(
      context,
      builder: (_) => ExploreHotPage.routeOf(context),
    );
  }
}

void goToExploreMostViewedPage(BuildContext context) {
  if (isMobilePlatform()) {
    context.navigator.push(CupertinoPageRoute(
      settings: const RouteSettings(
        name: RouterPageConstant.exploreMostViewed,
      ),
      builder: (_) => ExploreMostViewedPage.routeOf(context),
    ));
  } else {
    showDesktopWindow(
      context,
      builder: (_) => ExploreMostViewedPage.routeOf(context),
    );
  }
}

void goToSavedSearchPage(BuildContext context, String? username) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => SavedSearchFeedPage.of(context),
  ));
}

void goToSavedSearchEditPage(BuildContext context) {
  if (isMobilePlatform()) {
    context.navigator.push(CupertinoPageRoute(
      builder: (_) {
        return const SavedSearchPage();
      },
    ));
  } else {
    showDesktopWindow(
      context,
      width: min(context.screenWidth * 0.5, 600),
      builder: (_) => const SavedSearchPage(),
    );
  }
}

void goToPoolPage(BuildContext context, WidgetRef ref) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => const PoolPage(),
  ));
}

void goToBlacklistedTagPage(BuildContext context) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => const BlacklistedTagsPage(),
  ));
}

void goToDmailPage(BuildContext context) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => const DanbooruDmailPage(),
  ));
}

void goToArtistSearchPage(BuildContext context) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => const DanbooruArtistSearchPage(),
  ));
}

void goToCommentCreatePage(
  BuildContext context, {
  required int postId,
  String? initialContent,
}) {
  context.navigator.push(CupertinoPageRoute(
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
    CupertinoPageRoute(
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
    CupertinoPageRoute(
      builder: (_) => UserDetailsPage(
        uid: uid,
        username: username,
      ),
    ),
  );
}

void goToPoolSearchPage(BuildContext context, WidgetRef ref) {
  context.navigator.push(CupertinoPageRoute(
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
      backgroundColor: context.colorScheme.secondaryContainer,
      builder: (_) => EditSavedSearchSheet(
        initialValue: initialValue,
        onSubmit: (query, label) => ref
            .read(danbooruSavedSearchesProvider(ref.readConfig).notifier)
            .create(
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
          backgroundColor: context.colorScheme.secondaryContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            width: context.screenWidth * 0.8,
            height: context.screenHeight * 0.8,
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
              onSubmit: (query, label) => ref
                  .read(danbooruSavedSearchesProvider(ref.readConfig).notifier)
                  .create(
                    query: query,
                    label: label,
                    onCreated: (data) => showSimpleSnackBar(
                      context: context,
                      duration: const Duration(seconds: 1),
                      content:
                          const Text('saved_search.saved_search_added').tr(),
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
    backgroundColor: context.colorScheme.secondaryContainer,
    builder: (_) => EditSavedSearchSheet(
      title: 'saved_search.update_saved_search'.tr(),
      initialValue: savedSearch,
      onSubmit: (query, label) =>
          ref.read(danbooruSavedSearchesProvider(ref.readConfig).notifier).edit(
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
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => const FavoriteGroupsPage(),
  ));
}

void goToFavoriteGroupDetailsPage(
  BuildContext context,
  FavoriteGroup group,
) {
  context.navigator.push(CupertinoPageRoute(
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

Future<bool?> goToDanbooruShowTaglistPage(
  WidgetRef ref,
  BuildContext context,
  List<Tag> tags,
) {
  final config = ref.readConfig;
  final notifier = ref.read(danbooruBlacklistedTagsProvider(config).notifier);
  final globalNotifier = ref.read(globalBlacklistedTagsProvider.notifier);
  final favoriteNotifier = ref.read(favoriteTagsProvider.notifier);
  final color = context.colorScheme.onBackground;
  final textColor = context.colorScheme.background;

  return showMaterialModalBottomSheet<bool>(
    context: navigatorKey.currentContext ?? context,
    duration: const Duration(milliseconds: 200),
    expand: true,
    builder: (dialogContext) => ShowTagListPage(
      tags: tags,
      onOpenWiki: (tag) {
        launchWikiPage(config.url, tag.rawName);
      },
      onAddToBlacklist: config.hasLoginDetails()
          ? (tag) {
              notifier.addWithToast(
                tag: tag.rawName,
              );
            }
          : null,
      onAddToGlobalBlacklist: (tag) {
        globalNotifier.addTagWithToast(
          tag.rawName,
        );
      },
      onAddToFavoriteTags: (tag) {
        favoriteNotifier.add(tag.rawName).then(
              (_) => showSuccessToast(
                'Added',
                backgroundColor: color,
                textStyle: TextStyle(
                  color: textColor,
                ),
              ),
            );
      },
    ),
  );
}

void goToForumPage(BuildContext context) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => const DanbooruForumPage(),
  ));
}

void goToTagEditPage(
  BuildContext context, {
  required DanbooruPost post,
}) {
  if (Screen.of(context).size == ScreenSize.small) {
    context.navigator.push(CupertinoPageRoute(
      builder: (context) => TagEditPage(
        post: post,
      ),
    ));
  } else {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => TagEditPage(
        post: post,
      ),
    ));
  }
}
