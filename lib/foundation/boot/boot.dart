// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../loggers.dart';
import 'boot_data.dart';
import 'failsafe.dart';

Future<void> initializeApp({
  required Future<void> Function(BootData) bootFunc,
}) async {
  final appLogger = AppLogger(
    initialLevel: LogLevel.debug,
  );
  final logger = await loggerWith(appLogger);
  logger.debugBoot('Initialize logger');

  WidgetsFlutterBinding.ensureInitialized();

  final bootData = BootData(
    logger: logger,
    appLogger: appLogger,
  );

  try {
    logger.debugBoot('Booting...');
    await bootFunc(bootData);
  } catch (e, st) {
    logger.debugBoot('An error occurred during booting');
    await failsafe(
      error: e,
      stackTrace: st,
      appLogger: appLogger,
    );
  }
}
