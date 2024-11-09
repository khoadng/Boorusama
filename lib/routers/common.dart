// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/widgets/widgets.dart';

GoRouterPageBuilder genericMobilePageBuilder({
  required Widget Function(BuildContext context, GoRouterState state) builder,
}) =>
    (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: builder(context, state),
        );

GoRouterPageBuilder largeScreenAwarePageBuilder<T>({
  required Widget Function(BuildContext context, GoRouterState state) builder,
}) =>
    (context, state) {
      return context.orientation.isPortrait
          ? CupertinoPage<T>(
              key: state.pageKey,
              name: state.name,
              child: builder(context, state),
            )
          : FastFadePage<T>(
              key: state.pageKey,
              name: state.name,
              child: builder(context, state),
            );
    };

GoRouterPageBuilder platformAwarePageBuilder<T>({
  required Widget Function(BuildContext context, GoRouterState state) builder,
}) =>
    (context, state) => kPreferredLayout.isMobile
        ? CupertinoPage<T>(
            key: state.pageKey,
            name: state.name,
            child: builder(context, state),
          )
        : MaterialPage<T>(
            key: state.pageKey,
            name: state.name,
            child: builder(context, state),
          );

class FastFadePageRoute<T> extends PageRouteBuilder<T> {
  FastFadePageRoute({
    super.settings,
    required this.child,
  }) : super(
          transitionDuration: const Duration(milliseconds: 100),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: fadeTransitionBuilder(),
        );

  final Widget child;
}

class FastFadePage<T> extends CustomTransitionPage<T> {
  FastFadePage({
    required super.child,
    super.name,
    super.key,
  }) : super(
          transitionsBuilder: fadeTransitionBuilder(),
          transitionDuration: const Duration(milliseconds: 100),
          reverseTransitionDuration: const Duration(milliseconds: 100),
        );
}
