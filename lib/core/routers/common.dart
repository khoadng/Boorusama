// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../foundation/display.dart';
import '../widgets/widgets.dart';
import 'routers.dart';

GoRouterPageBuilder genericMobilePageBuilder({
  required Widget Function(BuildContext context, GoRouterState state) builder,
}) =>
    (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: builder(context, state),
        );

GoRouterPageBuilder largeScreenCompatPageBuilderWithExtra<T>({
  required Widget Function(BuildContext context, GoRouterState state, T extra)
      pageBuilder,
  String? errorScreenMessage,
  bool fullScreen = false,
}) =>
    (context, state) {
      final extra = state.extra as T?;

      if (extra == null) {
        return largeScreenAwarePageBuilder(
          useDialog: !fullScreen,
          builder: (context, state) => LargeScreenAwareInvalidPage(
            useDialog: !fullScreen,
            message: errorScreenMessage ?? 'Invalid parameters',
          ),
        )(context, state);
      }

      final builtPage = pageBuilder(context, state, extra);

      final page = context.isLargeScreen && !fullScreen
          ? BooruDialog(
              child: builtPage,
            )
          : builtPage;

      return largeScreenAwarePageBuilder(
        useDialog: !fullScreen,
        builder: (context, state) => page,
      )(context, state);
    };

GoRouterPageBuilder largeScreenAwarePageBuilder<T>({
  required Widget Function(BuildContext context, GoRouterState state) builder,
  bool useDialog = false,
}) =>
    (context, state) {
      return !context.isLargeScreen
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
    required this.child,
    super.settings,
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
