// Project imports:
import 'package:boorusama/router.dart';
import '../../../topics/topic.dart';
import '../forum_posts_page.dart';

final danbooruForumPostRoutes = GoRoute(
  path: ':id',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruForumTopic>(
    errorScreenMessage: 'Invalid topic',
    pageBuilder: (context, state, topic) => DanbooruForumPostsPage(
      topic: topic,
    ),
  ),
);
