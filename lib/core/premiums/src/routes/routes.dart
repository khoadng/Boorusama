// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../foundation/display.dart';
import '../../../router.dart';
import '../../../widgets/widgets.dart';
import '../pages/premium_page.dart';

export 'route_utils.dart';

final premiumRoutes = GoRoute(
  path: 'premium',
  name: '/premium',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) {
      final landscape = context.orientation.isLandscape;

      const page = PremiumPage();

      return landscape
          ? const BooruDialog(
              padding: EdgeInsets.all(8),
              child: page,
            )
          : page;
    },
  ),
);
