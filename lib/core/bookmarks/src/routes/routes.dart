// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../posts/listing/providers.dart';
import '../../../router.dart';
import '../data/bookmark_convert.dart';
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
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;

        return CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: BookmarkDetailsPage(
            initialIndex: state.uri.queryParameters['index']?.toInt() ?? 0,
            initialThumbnailUrl: extra['initialThumbnailUrl'] as String,
            controller: extra['controller'] as PostGridController<BookmarkPost>,
          ),
        );
      },
    ),
  ],
);
