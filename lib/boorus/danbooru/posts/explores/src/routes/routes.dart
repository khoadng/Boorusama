// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../pages/danbooru_explore_page.dart';
import '../pages/explore_hot_page.dart';
import '../pages/explore_most_viewed_page.dart';
import '../pages/explore_popular_page.dart';

final danbooruExploreRoutes = GoRoute(
  path: '/danbooru/explore',
  name: 'explore',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruExplorePage(),
  ),
  routes: [
    GoRoute(
      path: 'posts/popular',
      name: 'explore/popular',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        name: state.name,
        child: ExplorePopularPage.routeOf(context),
      ),
    ),
    GoRoute(
      path: 'posts/viewed',
      name: 'explore/viewed',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        name: state.name,
        child: ExploreMostViewedPage.routeOf(context),
      ),
    ),
  ],
);

final danbooruExploreHotRoutes = GoRoute(
  path: '/internal/danbooru/explore/posts/hot',
  name: 'explore/hot',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const ExploreHotPage(),
  ),
);
