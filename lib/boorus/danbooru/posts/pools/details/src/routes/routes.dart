// Project imports:
import '../../../../../../../router.dart';
import '../../../pool/pool.dart';
import '../pool_detail_page.dart';

final danbooruPoolDetailsRoutes = GoRoute(
  path: ':id',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPool>(
    errorScreenMessage: 'Invalid pool',
    pageBuilder: (context, state, pool) => PoolDetailPage(
      pool: pool,
    ),
  ),
);
