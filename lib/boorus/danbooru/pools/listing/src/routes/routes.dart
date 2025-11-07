// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../../../details/routes.dart';
import '../../../search/routes.dart';
import '../danbooru_pool_page.dart';

final danbooruPoolRoutes = GoRoute(
  path: '/danbooru/pools',
  name: 'pools',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruPoolPage(),
  ),
  routes: [
    danbooruPoolSearchRoutes,
    danbooruPoolDetailsRoutes,
  ],
);
