// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:boorusama/core/infra/loggers.dart';

abstract class LoggerService {
  void logI(String serviceName, String message);
  void logW(String serviceName, String message);
  void logE(String serviceName, String message);
}

Future<LoggerService> loggerWith(LoggerService logger) async {
  if (!kReleaseMode) {
    return MultiChannelLogger(
      loggers: [
        ConsoleLogger(),
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
