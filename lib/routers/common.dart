// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/dialog_page.dart';

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
  bool useDialog = false,
}) =>
    (context, state) {
      return context.orientation.isPortrait
          ? CupertinoPage<T>(
              key: state.pageKey,
              name: state.name,
              child: builder(context, state),
            )
          : useDialog
              ? DialogPage<T>(
                  key: state.pageKey,
                  name: state.name,
                  builder: (context) => builder(context, state),
                )
              : FastFadePage<T>(
                  key: state.pageKey,
                  name: state.name,
                  child: builder(context, state),
                );
    };

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
