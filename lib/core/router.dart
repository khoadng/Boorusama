// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../boorus/danbooru/router.dart';
import 'analytics/analytics_observer.dart';
import 'router.dart';

export 'package:boorusama/core/routers/routers.dart';

export 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routeObserver = RouteObserver();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    observers: [
      AnalyticsObserver(() => ref),
      routeObserver,
    ],
    routes: [
      Routes.home(ref),
      ...danbooruRoutes,
    ],
  );
});
