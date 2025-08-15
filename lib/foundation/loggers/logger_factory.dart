// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'console_logger.dart';
import 'logger.dart';
import 'multi_channel_logger.dart';

Future<Logger> loggerWith(Logger logger) async {
  return MultiChannelLogger(
    loggers: [
      if (!kReleaseMode)
        ThresholdLogger(
          delegate: ConsoleLogger(
            options: const ConsoleLoggerOptions(
              decodeUriParameters: true,
            ),
          ),
          initialLevel: LogLevel.verbose,
        ),
      ThresholdLogger(
        delegate: logger,
        initialLevel: LogLevel.debug,
      ),
    ],
  );
}
