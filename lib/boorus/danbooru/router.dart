// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
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
import 'tags/edit/routes.dart';
import 'users/details/routes.dart';
import 'users/user/routes.dart';
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
  danbooruTagEditRoutes,
  danbooruCommentRoutes,
  danbooruFavoriterListRoutes,
  danbooruVoterListRoutes,
];

final danbooruRoutes = [
  ...danbooruDirectRoutes,
  ...danbooruCustomRoutes,
];

// Danbooru direct mapping routes
final danbooruDirectRoutes = [
  danbooruProfileRoutes,
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
  danbooruUserDetailsRoutes,
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
