// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../core/router.dart';
import 'pages/saved_search_page.dart';

final danbooruSavedSearchRoutes = GoRoute(
  path: '/danbooru/saved_searches',
  name: 'saved_search_edit',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const SavedSearchPage(),
  ),
);
