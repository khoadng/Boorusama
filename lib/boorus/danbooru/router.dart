// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/router.dart';
import 'artists/search/routes.dart';
import 'blacklist/routes.dart';
import 'comments/comment/routes.dart';
import 'dmails/dmail.dart';
import 'dmails/dmail_page.dart';
import 'forums/posts/forum_posts_page.dart';
import 'forums/topics/forum_page.dart';
import 'forums/topics/forum_topic.dart';
import 'posts/explores/routes.dart';
import 'posts/favgroups/listing/routes.dart';
import 'posts/pools/listing/routes.dart';
import 'posts/post/post.dart';
import 'posts/uploads/routes.dart';
import 'saved_searches/feed/saved_search_feed_page.dart';
import 'saved_searches/listing/saved_search_page.dart';
import 'tags/edit/tag_edit_page.dart';
import 'tags/pages/danbooru_show_tag_list_page.dart';
import 'tags/related/danbooru_related_tag.dart';
import 'tags/related/related_tag_action_sheet.dart';
import 'users/details/user_details_page.dart';
import 'users/pages/user_list_page.dart';
import 'versions/danbooru_post_versions_page.dart';

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
  danbooruExploreHotRoutes,
  danbooruBlacklistRoutes,
  GoRoute(
    path: '/internal/danbooru/posts/:id/editor',
    pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPost>(
      errorScreenMessage: 'Invalid post',
      fullScreen: true,
      pageBuilder: (context, state, post) => DanbooruTagEditPage(
        post: post,
      ),
    ),
  ),
  danbooruCommentRoutes,
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
  danbooruArtistRoutes,
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
  danbooruFavgroupRoutes,
  danbooruExploreRoutes,
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
  danbooruPoolRoutes,
  danbooruUploadRoutes,
];

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
