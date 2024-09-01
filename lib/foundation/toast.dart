// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/flutter.dart';

void showSuccessToast(
  BuildContext context,
  String message, {
  Duration? duration,
  Color? backgroundColor,
  TextStyle? textStyle,
}) =>
    showToast(
      message,
      position: ToastPosition.bottom,
      margin: const EdgeInsets.all(100),
      textPadding: const EdgeInsets.all(8),
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      duration: duration,
    );

void showErrorToast(
  BuildContext context,
  String message, {
  Duration? duration,
}) =>
    showToast(
      message,
      position: ToastPosition.bottom,
      margin: const EdgeInsets.all(100),
      textPadding: const EdgeInsets.all(8),
      duration: duration,
      backgroundColor: Colors.red,
      textStyle: const TextStyle(
        color: Colors.white,
      ),
    );

void showSimpleSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  SnackBarBehavior? behavior,
  SnackBarAction? action,
}) {
  final snackBarBehavior = behavior ?? SnackBarBehavior.floating;
  final snackbar = SnackBar(
    action: action,
    behavior: snackBarBehavior,
    duration: duration ?? const Duration(seconds: 6),
    elevation: 6,
    width: _calculateSnackBarWidth(context, snackBarBehavior),
    content: content,
  );
  context.scaffoldMessenger.showSnackBar(snackbar);
}

double? _calculateSnackBarWidth(
  BuildContext context,
  SnackBarBehavior behavior,
) {
  if (behavior == SnackBarBehavior.fixed) return null;
  final width = context.screenWidth;

  return width > 400 ? 400 : width;
}
