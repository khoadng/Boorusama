// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../app.dart';
import '../../info/device_info.dart';
import '../loggers.dart';

Future<void> failsafe({
  required Object error,
  required StackTrace stackTrace,
  required BootLogger logger,
}) async {
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();
  final logs = logger.dump();

  runApp(
    ProviderScope(
      overrides: [
        deviceInfoProvider.overrideWithValue(deviceInfo),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: AppFailedToInitialize(
          error: error,
          stackTrace: stackTrace,
          logs: logs,
        ),
      ),
    ),
  );
}
