// ignore_for_file: use_full_hex_values_for_flutter_colors

// Flutter imports:
import 'package:flutter/material.dart';

Future<T?> showSideSheetFromLeft<T>({
  required Widget body,
  required BuildContext context,
  double? width,
  String barrierLabel = 'Side Sheet',
  bool barrierDismissible = true,
  Color barrierColor = const Color(0xFF66000000),
  Duration transitionDuration = const Duration(milliseconds: 200),
  RouteSettings? settings,
}) async => _showSheetSide<T>(
  body: body,
  width: width,
  rightSide: false,
  context: context,
  barrierLabel: barrierLabel,
  barrierDismissible: barrierDismissible,
  barrierColor: barrierColor,
  transitionDuration: transitionDuration,
  settings: settings,
);

Future<T?> showSideSheetFromRight<T>({
  required Widget body,
  required BuildContext context,
  double? width,
  String barrierLabel = 'Side Sheet',
  bool barrierDismissible = true,
  Color barrierColor = const Color(0xFF66000000),
  Duration transitionDuration = const Duration(milliseconds: 200),
  RouteSettings? settings,
}) => _showSheetSide<T>(
  body: body,
  width: width,
  rightSide: true,
  context: context,
  barrierLabel: barrierLabel,
  barrierDismissible: barrierDismissible,
  barrierColor: barrierColor,
  transitionDuration: transitionDuration,
  settings: settings,
);

Future<T?> _showSheetSide<T>({
  required Widget body,
  required bool rightSide,
  required BuildContext context,
  required String barrierLabel,
  required bool barrierDismissible,
  required Color barrierColor,
  required Duration transitionDuration,
  double? width,
  RouteSettings? settings,
}) => showGeneralDialog(
  barrierLabel: barrierLabel,
  barrierDismissible: barrierDismissible,
  barrierColor: barrierColor,
  transitionDuration: transitionDuration,
  context: context,
  routeSettings: settings,
  pageBuilder: (context, animation1, animation2) {
    return Align(
      alignment: rightSide ? Alignment.centerRight : Alignment.centerLeft,
      child: Material(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: Container(
          color: Colors.transparent,
          height: double.infinity,
          width: width ?? MediaQuery.sizeOf(context).width / 1.4,
          child: body,
        ),
      ),
    );
  },
  transitionBuilder: (context, animation1, animation2, child) {
    return SlideTransition(
      position: Tween(
        begin: Offset(rightSide ? 1 : -1, 0),
        end: Offset.zero,
      ).animate(animation1),
      child: child,
    );
  },
);
