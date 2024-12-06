// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'screen_size.dart';
import 'types.dart';

Future<T?> showAdaptiveSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  double? width,
  Color? backgroundColor,
  RouteSettings? settings,
}) {
  if (Screen.of(context).size == ScreenSize.small) {
    return showMaterialModalBottomSheet<T>(
      settings: settings,
      context: context,
      backgroundColor: backgroundColor,
      duration: AppDurations.bottomSheet,
      expand: expand,
      builder: builder,
    );
  } else {
    return showSideSheetFromRight<T>(
      settings: settings,
      width: width ?? 320,
      body: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        removeRight: true,
        child: builder(context),
      ),
      context: context,
    );
  }
}

Future<T?> showAdaptiveBottomSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  double? height,
  Color? backgroundColor,
  RouteSettings? settings,
}) {
  return Screen.of(context).size != ScreenSize.small
      ? showDialog<T>(
          context: context,
          routeSettings: settings,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 400,
                maxWidth: 500,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: builder(context),
            ),
          ),
        )
      : showAppModalBarBottomSheet<T>(
          context: context,
          settings: settings,
          barrierColor: Colors.black45,
          backgroundColor: backgroundColor ?? Colors.transparent,
          builder: (context) => ConditionalParentWidget(
            condition: !expand,
            child: builder(context),
            conditionalBuilder: (child) => SizedBox(
              height: height,
              child: child,
            ),
          ),
        );
}

Future<T?> showAppModalBarBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  ShapeBorder? shape,
  Color barrierColor = Colors.black87,
  bool bounce = true,
  bool expand = false,
  Curve? animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  Duration? duration,
  RouteSettings? settings,
}) =>
    showBarModalBottomSheet<T>(
      context: context,
      settings: settings,
      barrierColor: barrierColor,
      duration: duration ?? AppDurations.bottomSheet,
      backgroundColor: backgroundColor,
      shape: shape,
      bounce: bounce,
      expand: expand,
      animationCurve: animationCurve,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      builder: builder,
    );
