// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'boot.dart';

void main() async {
  final bootLogger = BootLogger();
  bootLogger.l("Initialize Flutter's widgets binding");
  WidgetsFlutterBinding.ensureInitialized();

  try {
    bootLogger.l("Bootstrap the app");

    await boot(bootLogger);
  } catch (e, st) {
    await failsafe(e, st, bootLogger);
  }
}
