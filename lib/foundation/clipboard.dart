// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:oktoast/oktoast.dart';
import 'package:pasteboard/pasteboard.dart';

// Project imports:
import 'animations/constants.dart';

abstract class AppClipboard {
  static Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  static Future<void> copyImageBytes(Uint8List bytes) =>
      Pasteboard.writeImage(bytes);

  static Future<String?> paste(String format) async {
    final data = await Clipboard.getData(format);
    return data?.text;
  }

  static Future<void> copyAndToast(
    BuildContext context,
    String text, {
    required String message,
  }) async {
    await copy(text);
    showToast(
      message,
      position: ToastPosition.bottom,
      textPadding: const EdgeInsets.all(8),
      duration: AppDurations.shortToast,
    );
  }

  static Future<void> copyWithDefaultToast(
    BuildContext context,
    String text,
  ) => copyAndToast(
    context,
    text,
    message: 'Copied',
  );
}
