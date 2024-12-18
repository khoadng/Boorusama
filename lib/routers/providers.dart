// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:boorusama/foundation/analytics.dart';
import 'routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final analytics = ref.watch(analyticsProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    observers: [
      analytics.getAnalyticsObserver(),
    ],
    routes: [
      Routes.home(ref),
    ],
  );
});

class RouterBuilder extends ConsumerWidget {
  const RouterBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, GoRouter router) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return builder(context, router);
  }
}
