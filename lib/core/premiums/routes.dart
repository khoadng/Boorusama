// Project imports:
import '../router.dart';
import '../widgets/widgets.dart';
import 'premium_page.dart';

export 'route_utils.dart';

final premiumRoutes = GoRoute(
  path: 'premium',
  name: '/premium',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) => const BooruDialog(
      child: PremiumPage(),
    ),
  ),
);