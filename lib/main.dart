// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/instance.dart';
import 'package:boorusama/main_2.dart';
import 'boot.dart';

void main() async {
  final bootLogger = BootLogger();

  final server = await AppInstanceServer.instance.createServer();

  if (server == null) {
    mainInstance();
    return;
  }

  // Ensure cleanup when the app exits
  ProcessSignal.sigint.watch().listen((signal) async {
    await AppInstanceServer.instance.dispose();
    exit(0);
  });

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
