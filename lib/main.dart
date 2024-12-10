// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'core/boot.dart';
import 'core/foundation/loggers.dart';

void main() async {
  final bootLogger = BootLogger();

  bootLogger.l("Initialize Flutter's widgets binding");
  WidgetsFlutterBinding.ensureInitialized();
  try {
    bootLogger.l('Booting...');
    await boot(bootLogger);
  } catch (e, st) {
    bootLogger.l('An error occurred during booting');
    await failsafe(e, st, bootLogger);
  }
}
