// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../../types.dart';
import '../pool_detail_page.dart';
import '../pool_page.dart';
import '../pool_search_page.dart';

final szurubooruPoolRoutes = GoRoute(
  path: '/szurubooru/pools',
  name: 'szurubooru_pools',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const SzurubooruPoolPage(),
  ),
  routes: [
    GoRoute(
      path: 'search',
      name: 'szurubooru_pool_search',
      builder: (context, state) => const SzurubooruPoolSearchPage(),
    ),
    GoRoute(
      path: ':id',
      name: 'szurubooru_pool_details',
      pageBuilder: (context, state) {
        final poolId = int.tryParse(state.pathParameters['id'] ?? '');

        if (poolId == null) {
          return CupertinoPage(
            key: state.pageKey,
            name: state.name,
            child: const InvalidPage(message: 'Invalid pool'),
          );
        }

        return largeScreenAwarePageBuilder(
          useDialog: true,
          builder: (context, state) => SzurubooruPoolDetailPage(
            poolId: poolId,
            initialPool: switch (state.extra) {
              final SzurubooruPool pool => pool,
              _ => null,
            },
          ),
        )(context, state);
      },
    ),
  ],
);
