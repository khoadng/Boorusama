// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'console_logger.dart';
import 'logger.dart';
import 'multi_channel_logger.dart';

Future<Logger> loggerWith(Logger logger) async {
  if (!kReleaseMode) {
    return MultiChannelLogger(
      loggers: [
        ConsoleLogger(
          options: const ConsoleLoggerOptions(
            decodeUriParameters: true,
          ),
        ),
        logger,
      ],
    );
  } else {
    return MultiChannelLogger(
      loggers: [
        logger,
      ],
    );
  }
}
