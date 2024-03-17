// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stack_trace/stack_trace.dart';

// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'boot.dart';

void main() async {
  final bootLogger = BootLogger();
  bootLogger.l("Initialize Flutter's widgets binding");
  WidgetsFlutterBinding.ensureInitialized();

  Chain.capture(
    () async {
      bootLogger.l("Bootstrap the app");

      await boot(bootLogger);
    },
    onError: (e, st) async {
      await failsafe(e, st, bootLogger);
    },
  );
}
