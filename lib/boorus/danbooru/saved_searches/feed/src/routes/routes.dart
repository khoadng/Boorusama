// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../saved_search_feed_page.dart';

final danbooruSavedSearchFeedRoutes = GoRoute(
  path: '/internal/danbooru/saved_searches/feed',
  name: 'saved_search_feed',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const SavedSearchFeedPage(),
  ),
);
