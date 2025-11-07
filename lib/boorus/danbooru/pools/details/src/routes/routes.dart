// Project imports:
import '../../../../../../core/router.dart';
import '../../../pool/types.dart';
import '../pool_detail_page.dart';

final danbooruPoolDetailsRoutes = GoRoute(
  path: ':id',
  name: 'pool_details',
  pageBuilder: largeScreenCompatPageBuilderWithExtra<DanbooruPool>(
    errorScreenMessage: 'Invalid pool',
    pageBuilder: (context, state, pool) => PoolDetailPage(
      pool: pool,
    ),
  ),
);
