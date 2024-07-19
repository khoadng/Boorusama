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
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/core/wikis/wikis.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'artists/artists.dart';
import 'blacklist/blacklist.dart';
import 'comments/comments.dart';
import 'dmails/dmails.dart';
import 'explores/explore_hot_page.dart';
import 'explores/explore_most_viewed_page.dart';
import 'explores/explore_popular_page.dart';
import 'favorite_groups/favorite_groups.dart';
import 'forums/danbooru_forum_page.dart';
import 'pools/pool_detail_page.dart';
import 'pools/pool_search_page.dart';
import 'pools/pools.dart';
import 'posts/posts.dart';
import 'related_tags/related_tags.dart';
import 'router_page_constant.dart';
import 'saved_searches/saved_searches.dart';
import 'tags/tags.dart';
import 'uploads/danbooru_my_uploads_page.dart';
import 'uploads/uploads.dart';
import 'users/user_details_page.dart';
import 'versions/danbooru_post_versions_page.dart';

void goToPoolDetailPage(BuildContext context, DanbooruPool pool) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => PoolDetailPage.of(context, pool: pool),
  ));
}

void goToPostVersionPage(BuildContext context, DanbooruPost post) {
  if (kPreferredLayout.isMobile) {
    showMaterialModalBottomSheet(
      context: context,
      duration: AppDurations.bottomSheet,
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
  if (kPreferredLayout.isMobile) {
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
  if (kPreferredLayout.isMobile) {
    context.navigator.push(CupertinoPageRoute(
      settings: const RouteSettings(
        name: RouterPageConstant.exploreHot,
      ),
      builder: (_) => const ExploreHotPage(),
    ));
  } else {
    showDesktopWindow(
      context,
      builder: (_) => const ExploreHotPage(),
    );
  }
}

void goToExploreMostViewedPage(BuildContext context) {
  if (kPreferredLayout.isMobile) {
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
  if (kPreferredLayout.isMobile) {
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
    builder: (_) => const DanbooruPoolPage(),
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
  bool isSelf = false,
}) {
  final page = UserDetailsPage(
    uid: uid,
    username: username,
    isSelf: isSelf,
  );

  if (Screen.of(context).size == ScreenSize.small) {
    context.navigator.push(
      CupertinoPageRoute(
        builder: (_) => page,
      ),
    );
  } else {
    showSideSheetFromRight(
      body: page,
      context: context,
      width: 480,
    );
  }
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
  required void Function(RelatedTagItem tag) onAdded,
  required void Function(RelatedTagItem tag) onNegated,
}) {
  showAdaptiveSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.relatedTags,
    ),
    builder: (context) => RelatedTagActionSheet(
      relatedTag: relatedTag,
      onAdded: onAdded,
      onNegated: onNegated,
    ),
  );
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
  if (kPreferredLayout.isMobile) {
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
                duration: AppDurations.shortToast,
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
                      duration: AppDurations.shortToast,
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
                  duration: AppDurations.shortToast,
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
      padding: kPreferredLayout.isMobile ? 0 : 8,
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
      padding: kPreferredLayout.isMobile ? 0 : 8,
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
    duration: AppDurations.bottomSheet,
    expand: true,
    builder: (_) => AddToFavoriteGroupPage(
      posts: posts,
    ),
  );
}

Future<bool?> goToDanbooruShowTaglistPage(
  WidgetRef ref,
  List<Tag> tags,
) {
  final config = ref.readConfig;
  final notifier = ref.read(danbooruBlacklistedTagsProvider(config).notifier);
  final globalNotifier = ref.read(globalBlacklistedTagsProvider.notifier);
  final favoriteNotifier = ref.read(favoriteTagsProvider.notifier);
  final color = ref.context.colorScheme.onSurface;
  final textColor = ref.context.colorScheme.surface;

  return showAdaptiveSheet(
    navigatorKey.currentContext ?? ref.context,
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

void goToTagEditUploadPage(
  BuildContext context, {
  required DanbooruUploadPost post,
  required void Function() onSubmitted,
}) {
  if (Screen.of(context).size == ScreenSize.small) {
    context.navigator.push(CupertinoPageRoute(
      builder: (context) => TagEditUploadPage(
        post: post,
        onSubmitted: onSubmitted,
      ),
    ));
  } else {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => TagEditUploadPage(
        post: post,
        onSubmitted: onSubmitted,
      ),
    ));
  }
}

void goToMyUploadsPage(BuildContext context, int userId) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => DanbooruMyUploadsPage(
      userId: userId,
    ),
  ));
}
