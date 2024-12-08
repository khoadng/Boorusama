// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/router.dart';
import 'boorus/danbooru/router.dart';

export 'package:boorusama/routers/routers.dart';

export 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routeObserver = RouteObserver();

final routerProvider = Provider<GoRouter>((ref) {
  final analytics = ref.watch(analyticsProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    observers: [
      analytics.getAnalyticsObserver(),
      routeObserver,
    ],
    routes: [
      Routes.home(ref),
      ...danbooruRoutes,
    ],
  );
});
