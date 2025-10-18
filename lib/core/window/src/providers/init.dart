// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:window_manager/window_manager.dart';

Future<void> initialize() async {
  await windowManager.ensureInitialized();

  unawaited(
    windowManager.waitUntilReadyToShow(
      const WindowOptions(
        minimumSize: Size(350, 350),
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    ),
  );
}
