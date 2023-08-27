// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:oktoast/oktoast.dart';

void showSuccessToast(
  String message, {
  Duration? duration,
}) =>
    showToast(
      message,
      position: ToastPosition.bottom,
      margin: const EdgeInsets.all(100),
      textPadding: const EdgeInsets.all(8),
      duration: duration,
    );

void showErrorToast(
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
