// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import 'app_logger.dart';

AppLogger createAppLogger({LogLevel initialLevel = LogLevel.info}) => AppLogger(
  initialLevel: initialLevel,
  output: kReleaseMode
      ? null
      : ConsoleLogger(
          options: const ConsoleLoggerOptions(decodeUriParameters: true),
        ),
);
