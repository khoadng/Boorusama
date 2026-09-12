import 'package:flutter/foundation.dart';

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
