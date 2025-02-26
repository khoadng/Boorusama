// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'drag_line.dart';

class BooruBottomSheet extends StatelessWidget {
  const BooruBottomSheet({
    required this.child,
    super.key,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DragLine(),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResizeToAvoidBottomInset extends StatelessWidget {
  const _ResizeToAvoidBottomInset({
    required this.child,
    this.resizeToAvoidBottomInset = false,
  });

  final bool resizeToAvoidBottomInset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return resizeToAvoidBottomInset
        ? _ViewInsetBottomPadding(child: child)
        : child;
  }
}

class _ViewInsetBottomPadding extends StatelessWidget {
  const _ViewInsetBottomPadding({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: child,
    );
  }
}

Future<T?> showBooruModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  RouteSettings? routeSettings,
  bool enableDrag = true,
  bool resizeToAvoidBottomInset = false,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    enableDrag: enableDrag,
    routeSettings: routeSettings,
    scrollControlDisabledMaxHeightRatio: 0.9,
    builder: (context) => _ResizeToAvoidBottomInset(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: BooruBottomSheet(
        backgroundColor: backgroundColor,
        child: builder(context),
      ),
    ),
  );
}
