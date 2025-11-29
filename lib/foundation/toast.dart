// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:oktoast/oktoast.dart';

void showSuccessToast(
  BuildContext context,
  String message, {
  Duration? duration,
  Color? backgroundColor,
  TextStyle? textStyle,
}) => showToast(
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
}) => showToast(
  message,
  position: ToastPosition.bottom,
  margin: const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 60,
  ),
  textPadding: const EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  ),
  duration: duration ?? const Duration(seconds: 4),
  backgroundColor: Theme.of(context).colorScheme.error,
  textStyle: TextStyle(
    color: Theme.of(context).colorScheme.onError,
    fontSize: 14,
    fontWeight: FontWeight.w500,
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
    duration: duration ?? const Duration(seconds: 4),
    elevation: 6,
    width: _calculateSnackBarWidth(context, snackBarBehavior),
    content: content,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

double? _calculateSnackBarWidth(
  BuildContext context,
  SnackBarBehavior behavior,
) {
  if (behavior == SnackBarBehavior.fixed) return null;
  final width = MediaQuery.maybeWidthOf(context) ?? 400;

  return width > 400 ? 400 : width;
}
