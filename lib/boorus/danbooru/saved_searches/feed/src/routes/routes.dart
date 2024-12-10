// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:boorusama/router.dart';
import '../saved_search_feed_page.dart';

final danbooruSavedSearchFeedRoutes = GoRoute(
  path: '/internal/danbooru/saved_searches/feed',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const SavedSearchFeedPage(),
  ),
);
