// Project imports:
import '../../../router.dart';
import '../pages/blacklisted_tag_page.dart';

final globalBlacklistedTagsRoutes = GoRoute(
  path: 'global_blacklisted_tags',
  name: '/global_blacklisted_tags',
  pageBuilder: genericMobilePageBuilder(
    builder: (context, state) => const BlacklistedTagPage(),
  ),
);
