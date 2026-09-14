// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart' hide GoRouterHelper;

// Project imports:
import '../boorus/danbooru/router.dart';
import '../boorus/eshuushuu/router.dart';
import '../boorus/shimmie2/router.dart';
import '../boorus/szurubooru/router.dart';
import 'analytics/analytics_observer.dart';
import 'navigation/app_navigation.dart';
import 'routers/routers.dart';

export 'package:boorusama/core/routers/routers.dart';

export 'navigation/app_navigation.dart';

export 'package:go_router/go_router.dart' hide GoRouterHelper;

final routerProvider = Provider<GoRouter>((ref) {
  final navigation = ref.watch(appNavigationProvider);
  final router = GoRouter(
    navigatorKey: navigation.navigatorKey,
    observers: [
      AnalyticsObserver(() => ref),
      navigation.routeObserver,
    ],
    routes: [
      Routes.home(ref),
      ...danbooruRoutes,
      ...eshuushuuRoutes,
      ...shimmie2Routes,
      ...szurubooruRoutes,
    ],
  );

  ref.onDispose(router.dispose);

  return router;
});

extension RouterRef on WidgetRef {
  GoRouter get router => read(routerProvider);
}
