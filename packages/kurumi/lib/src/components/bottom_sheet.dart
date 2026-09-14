import 'package:material_ui/material_ui.dart';

import 'drag_line.dart';

class KurumiBottomSheet extends StatelessWidget {
  const KurumiBottomSheet({
    required this.child,
    super.key,
    this.backgroundColor,
    this.showDragHandle = true,
    this.useSafeArea = false,
  });

  final Widget child;
  final Color? backgroundColor;
  final bool showDragHandle;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: backgroundColor ?? colorScheme.surfaceContainer,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: useSafeArea,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KurumiDragLine(),
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
  const _ViewInsetBottomPadding({required this.child});

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

Future<T?> showKurumiModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  RouteSettings? routeSettings,
  bool enableDrag = true,
  bool showDragHandle = true,
  bool resizeToAvoidBottomInset = false,
  bool useSafeArea = false,
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
      child: KurumiBottomSheet(
        backgroundColor: backgroundColor,
        showDragHandle: showDragHandle,
        useSafeArea: useSafeArea,
        child: builder(context),
      ),
    ),
  );
}
