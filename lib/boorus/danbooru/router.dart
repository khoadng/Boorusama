// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/pools/pool_detail_page.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'blacklist/blacklist.dart';
import 'comments/comments.dart';
import 'dmails/dmails.dart';
import 'explores/explores.dart';
import 'favorite_groups/favorite_groups.dart';
import 'forums/forums.dart';
import 'pools/pool_search_page.dart';
import 'pools/pools.dart';
import 'posts/posts.dart';
import 'related_tags/related_tags.dart';
import 'saved_searches/saved_searches.dart';
import 'tags/danbooru_show_tag_list_page.dart';
import 'tags/tags.dart';
import 'uploads/danbooru_my_uploads_page.dart';
import 'uploads/uploads.dart';
import 'users/users.dart';
import 'versions/versions.dart';

// Internal custom routes
final danbooruCustomRoutes = [
  GoRoute(
    path: '/internal/danbooru/saved_searches/feed',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const SavedSearchFeedPage(),
    ),
  ),
  GoRoute(
    path: '/internal/danbooru/explore/posts/hot',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const ExploreHotPage(),
    ),
  ),
  GoRoute(
    path: '/internal/danbooru/settings/blacklist',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const DanbooruBlacklistedTagsPage(),
    ),
  ),
  GoRoute(
    path: '/internal/danbooru/posts/:id/editor',
    pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPost>(
      errorScreenMessage: 'Invalid post',
      fullScreen: true,
      pageBuilder: (context, state, post) => TagEditPage(
        post: post,
      ),
    ),
  ),
  GoRoute(
    path: '/internal/danbooru/posts/:id/comments/editor',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: Builder(
        builder: (context) {
          final postId = int.tryParse(state.pathParameters['id'] ?? '');
          final text = state.uri.queryParameters['text'];
          final commentId =
              int.tryParse(state.uri.queryParameters['comment_id'] ?? '');

          if (postId == null) {
            return const InvalidPage(
              message: 'Invalid post ID',
            );
          }

          if (commentId != null && text != null) {
            return CommentUpdatePage(
              postId: postId,
              commentId: commentId,
              initialContent: text,
            );
          } else {
            return CommentCreatePage(
              postId: postId,
              initialContent: text,
            );
          }
        },
      ),
    ),
  ),
  GoRoute(
    path: '/internal/danbooru/posts/:id/favoriter',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: Builder(
        builder: (context) {
          final postId = int.tryParse(state.pathParameters['id'] ?? '');

          if (postId == null) {
            return const InvalidPage(
              message: 'Invalid post ID',
            );
          }

          return DanbooruFavoriterListPage(postId: postId);
        },
      ),
    ),
  ),
  GoRoute(
    path: '/internal/danbooru/posts/:id/voter',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: Builder(
        builder: (context) {
          final postId = int.tryParse(state.pathParameters['id'] ?? '');

          if (postId == null) {
            return const InvalidPage(
              message: 'Invalid post ID',
            );
          }

          return DanbooruVoterListPage(postId: postId);
        },
      ),
    ),
  ),
];

final danbooruRoutes = [
  ...danbooruDirectRoutes,
  ...danbooruCustomRoutes,
];

// Danbooru direct mapping routes
final danbooruDirectRoutes = [
  GoRoute(
    path: '/danbooru/profile',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const DanbooruProfilePage(),
    ),
  ),
  GoRoute(
    path: '/danbooru/dmails',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const DanbooruDmailPage(),
    ),
  ),
  GoRoute(
    path: '/danbooru/artists',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const DanbooruArtistSearchPage(),
    ),
  ),
  GoRoute(
    path: '/danbooru/forum_topics',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const DanbooruForumPage(),
    ),
    routes: [
      GoRoute(
        path: ':id',
        pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruForumTopic>(
          errorScreenMessage: 'Invalid topic',
          pageBuilder: (context, state, topic) => DanbooruForumPostsPage(
            topic: topic,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/danbooru/favorite_groups',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const FavoriteGroupsPage(),
    ),
    routes: [
      GoRoute(
        path: ':id',
        pageBuilder:
            largeScreenCompatPageBuilderWithExtra<DanbooruFavoriteGroup>(
          errorScreenMessage: 'Invalid group',
          fullScreen: true,
          pageBuilder: (context, state, group) => FavoriteGroupDetailsPage(
            group: group,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/danbooru/explore',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const DanbooruExplorePage(),
    ),
    routes: [
      GoRoute(
        path: 'posts/popular',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: ExplorePopularPage.routeOf(context),
        ),
      ),
      GoRoute(
        path: 'posts/viewed',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: ExploreMostViewedPage.routeOf(context),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/danbooru/saved_searches',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const SavedSearchPage(),
    ),
  ),
  GoRoute(
    path: '/danbooru/users/:id',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: Builder(
        builder: (context) {
          final userId = int.tryParse(state.pathParameters['id'] ?? '');

          if (userId == null) {
            return const InvalidPage(
              message: 'Invalid user ID',
            );
          }

          return UserDetailsPage(
            uid: userId,
          );
        },
      ),
    ),
  ),
  GoRoute(
    path: '/danbooru/post_versions',
    pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPost>(
      errorScreenMessage: 'Invalid post',
      pageBuilder: (context, state, post) => DanbooruPostVersionsPage.post(
        post: post,
      ),
    ),
  ),
  GoRoute(
    path: '/danbooru/pools',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const DanbooruPoolPage(),
    ),
    routes: [
      GoRoute(
        path: 'search',
        pageBuilder: largeScreenAwarePageBuilder(
          useDialog: true,
          builder: (context, state) => const PoolSearchPage(),
        ),
      ),
      GoRoute(
        path: ':id',
        pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPool>(
          errorScreenMessage: 'Invalid pool',
          pageBuilder: (context, state, pool) => PoolDetailPage(
            pool: pool,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/danbooru/uploads',
    pageBuilder: largeScreenAwarePageBuilder(
      builder: (context, state) => const DanbooruUploadsPage(),
    ),
    routes: [
      GoRoute(
        path: ':id',
        pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruUploadPost>(
          errorScreenMessage: 'Invalid upload',
          fullScreen: true,
          pageBuilder: (context, state, post) => TagEditUploadPage(
            post: post,
          ),
        ),
      ),
    ],
  ),
];

void goToPoolDetailPage(BuildContext context, DanbooruPool pool) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'pools',
        '${pool.id}',
      ],
    ).toString(),
    extra: pool,
  );
}

void goToPostVersionPage(BuildContext context, DanbooruPost post) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'post_versions',
      ],
      queryParameters: {
        'search[post_id]': post.id.toString(),
      },
    ).toString(),
    extra: post,
  );
}

void goToExplorePage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'explore',
      ],
    ).toString(),
  );
}

void goToExplorePopularPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'explore',
        'posts',
        'popular',
      ],
    ).toString(),
  );
}

void goToExploreHotPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'explore',
        'posts',
        'hot',
      ],
    ).toString(),
  );
}

void goToExploreMostViewedPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'explore',
        'posts',
        'viewed',
      ],
    ).toString(),
  );
}

void goToSavedSearchPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'saved_searches',
        'feed',
      ],
    ).toString(),
  );
}

void goToSavedSearchEditPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'saved_searches',
      ],
    ).toString(),
  );
}

void goToPoolPage(BuildContext context, WidgetRef ref) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'pools',
      ],
    ).toString(),
  );
}

void goToBlacklistedTagPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'settings',
        'blacklist',
      ],
    ).toString(),
  );
}

void goToDmailPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'dmails',
      ],
    ).toString(),
  );
}

void goToDmailDetailsPage(
  BuildContext context, {
  required Dmail dmail,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'dmails',
        '${dmail.id}',
      ],
    ).toString(),
    extra: dmail,
  );
}

void goToArtistSearchPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'artists',
      ],
    ).toString(),
  );
}

void goToCommentCreatePage(
  BuildContext context, {
  required int postId,
  String? initialContent,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '$postId',
        'comments',
        'editor',
      ],
      queryParameters: {
        if (initialContent != null) 'text': initialContent,
      },
    ).toString(),
  );
}

void goToCommentUpdatePage(
  BuildContext context, {
  required int postId,
  required int commentId,
  required String commentBody,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '$postId',
        'comments',
        'editor',
      ],
      queryParameters: {
        'text': commentBody,
        'comment_id': commentId.toString(),
      },
    ).toString(),
  );
}

void goToProfilePage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'profile',
      ],
    ).toString(),
  );
}

void goToUserDetailsPage(
  BuildContext context, {
  required int uid,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'users',
        '$uid',
      ],
    ).toString(),
  );
}

void goToPoolSearchPage(BuildContext context, WidgetRef ref) {
  context.push(
    Uri(
      path: '/danbooru/pools/search',
    ).toString(),
  );
}

void goToRelatedTagsPage(
  BuildContext context, {
  required DanbooruRelatedTag relatedTag,
  required void Function(DanbooruRelatedTagItem tag) onAdded,
  required void Function(DanbooruRelatedTagItem tag) onNegated,
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
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '${post.id}',
        'favoriter',
      ],
    ).toString(),
  );
}

void goToPostVotesDetails(BuildContext context, DanbooruPost post) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '${post.id}',
        'voter',
      ],
    ).toString(),
  );
}

void goToSavedSearchCreatePage(
  BuildContext context, {
  String? initialValue,
}) {
  if (kPreferredLayout.isMobile) {
    showMaterialModalBottomSheet(
      context: context,
      settings: const RouteSettings(
        name: RouterPageConstant.savedSearchCreate,
      ),
      backgroundColor: context.colorScheme.surfaceContainer,
      builder: (_) => CreateSavedSearchSheet(
        initialValue: initialValue,
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
            child: CreateSavedSearchSheet(
              initialValue: initialValue,
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
) {
  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.savedSearchPatch,
    ),
    backgroundColor: context.colorScheme.surfaceContainer,
    builder: (_) => EditSavedSearchSheet(
      savedSearch: savedSearch,
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
  DanbooruFavoriteGroup group,
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
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'favorite_groups',
      ],
    ).toString(),
  );
}

void goToFavoriteGroupDetailsPage(
  BuildContext context,
  DanbooruFavoriteGroup group,
) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'favorite_groups',
        '${group.id}',
      ],
    ).toString(),
    extra: group,
  );
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
  return showAdaptiveSheet(
    navigatorKey.currentContext ?? ref.context,
    expand: true,
    builder: (context) => DanbooruShowTagListPage(
      tags: tags,
    ),
  );
}

void goToForumPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'forum_topics',
      ],
    ).toString(),
  );
}

void goToForumPostsPage(
  BuildContext context, {
  required DanbooruForumTopic topic,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'forum_topics',
        '${topic.id}',
      ],
    ).toString(),
    extra: topic,
  );
}

void goToTagEditPage(
  BuildContext context, {
  required DanbooruPost post,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '${post.id}',
        'editor',
      ],
    ).toString(),
    extra: post,
  );
}

void goToTagEditUploadPage(
  BuildContext context, {
  required DanbooruUploadPost post,
  required int uploadId,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'uploads',
        '$uploadId',
      ],
    ).toString(),
    extra: post,
  );
}

void goToMyUploadsPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'uploads',
      ],
    ).toString(),
  );
}
