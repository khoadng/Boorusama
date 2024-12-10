// Project imports:
import '../../../../../../../router.dart';
import '../pool_search_page.dart';

final danbooruPoolSearchRoutes = GoRoute(
  path: 'search',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) => const PoolSearchPage(),
  ),
);
