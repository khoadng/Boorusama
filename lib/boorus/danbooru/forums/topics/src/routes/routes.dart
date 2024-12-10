// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:boorusama/router.dart';
import '../../../posts/routes.dart';
import '../forum_page.dart';

final danbooruForumRoutes = GoRoute(
  path: '/danbooru/forum_topics',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruForumPage(),
  ),
  routes: [
    danbooruForumPostRoutes,
  ],
);
