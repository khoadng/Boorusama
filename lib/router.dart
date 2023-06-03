// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'core/analytics.dart';
import 'core/provider.dart';
import 'routes.dart';

export 'package:go_router/go_router.dart' hide GoRouterHelper;

final routerProvider = Provider((ref) {
  final settings = ref.watch(settingsProvider);

  return GoRouter(
    observers: [
      if (isAnalyticsEnabled(settings)) getAnalyticsObserver(),
    ],
    routes: [
      Routes.home(ref),
    ],
  );
});

class Router {
  static GoRouter of(BuildContext context) => GoRouter.of(context);
}

extension RouterX on BuildContext {
  void go(
    String location, {
    Object? extra,
  }) =>
      Router.of(this).go(
        location,
        extra: extra,
      );
}

class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final WidgetBuilder builder;

  const DialogPage({
    required this.builder,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
        context: context,
        settings: this,
        builder: builder,
        anchorPoint: anchorPoint,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        themes: themes,
      );
}
