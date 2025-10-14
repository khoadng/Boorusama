// Project imports:
import '../../../../../../core/router.dart';
import '../../../topics/types.dart';
import '../forum_posts_page.dart';

final danbooruForumPostRoutes = GoRoute(
  path: ':id',
  name: 'forum_posts',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruForumTopic>(
    errorScreenMessage: 'Invalid topic',
    pageBuilder: (context, state, topic) => DanbooruForumPostsPage(
      topic: topic,
    ),
  ),
);
