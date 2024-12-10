// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../../router.dart';
import '../../../details/routes.dart';
import '../pages/favorite_groups_page.dart';

final danbooruFavgroupRoutes = GoRoute(
  path: '/danbooru/favorite_groups',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const FavoriteGroupsPage(),
  ),
  routes: [
    danbooruFavgroupDetailsRoutes,
  ],
);
