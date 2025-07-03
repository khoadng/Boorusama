// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../loggers.dart';
import 'boot_data.dart';
import 'failsafe.dart';

Future<void> initializeApp({
  required Future<void> Function(BootData) bootFunc,
}) async {
  final bootLogger = BootLogger()..l("Initialize Flutter's widgets binding");
  final appLogger = AppLogger();
  bootLogger.l('Initialize app logger');
  final logger = await loggerWith(appLogger);

  WidgetsFlutterBinding.ensureInitialized();

  final bootData = BootData(
    bootLogger: bootLogger,
    logger: logger,
    appLogger: appLogger,
  );

  try {
    bootLogger.l('Booting...');
    await bootFunc(bootData);
  } catch (e, st) {
    bootLogger.l('An error occurred during booting');
    await failsafe(
      error: e,
      stackTrace: st,
      logger: bootLogger,
    );
  }
}
