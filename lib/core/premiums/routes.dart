// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../router.dart';
import 'premium_page.dart';

export 'route_utils.dart';

final premiumRoutes = GoRoute(
  path: 'premium',
  name: '/premium',
  pageBuilder: (context, state) {
    return CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: const PremiumPage(),
    );
  },
);
