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

GoRouterPageBuilder largeScreenAwarePageBuilder({
  required Widget Function(BuildContext context, GoRouterState state) builder,
}) =>
    (context, state) {
      return context.orientation.isPortrait
          ? CupertinoPage(
              key: state.pageKey,
              name: state.name,
              child: builder(context, state),
            )
          : CustomTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: builder(context, state),
              transitionDuration: const Duration(milliseconds: 200),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: fadeTransitionBuilder(),
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
