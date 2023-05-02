import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

void showSuccessToast(String message) => showToast(
      message,
      position: ToastPosition.bottom,
      margin: const EdgeInsets.all(100),
      textPadding: const EdgeInsets.all(8),
    );

void showErrorToast(String message) => showToast(
      message,
      position: ToastPosition.bottom,
      margin: const EdgeInsets.all(100),
      textPadding: const EdgeInsets.all(8),
      backgroundColor: Colors.red,
      textStyle: const TextStyle(
        color: Colors.white,
      ),
    );
