// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../router.dart';
import '../pages/bookmark_details_page.dart';
import '../pages/bookmark_page.dart';

final bookmarkRoutes = GoRoute(
  path: 'bookmarks',
  name: '/bookmarks',
  pageBuilder: genericMobilePageBuilder(
    builder: (context, state) => const BookmarkPage(),
  ),
  routes: [
    GoRoute(
      path: 'details',
      name: '/bookmarks/details',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        name: '${state.name}?index=${state.uri.queryParameters['index']}',
        child: BookmarkDetailsPage(
          initialIndex: state.uri.queryParameters['index']?.toInt() ?? 0,
        ),
      ),
    ),
  ],
);
