// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';

enum LogLevel {
  info,
  warning,
  error,
}

abstract class Logger {
  void logI(String serviceName, String message);
  void logW(String serviceName, String message);
  void logE(String serviceName, String message);
  void log(
    String serviceName,
    String message, {
    LogLevel? level,
  });
}

mixin LoggerMixin {
  Logger get logger;

  void logI(String serviceName, String message) =>
      logger.logI(serviceName, message);

  void logW(String serviceName, String message) =>
      logger.logW(serviceName, message);

  void logE(String serviceName, String message) =>
      logger.logE(serviceName, message);

  void log(
    String serviceName,
    String message, {
    LogLevel? level,
  }) =>
      logger.log(serviceName, message, level: level);
}

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
