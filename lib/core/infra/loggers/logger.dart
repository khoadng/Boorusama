// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:boorusama/core/infra/loggers.dart';
import 'package:boorusama/core/infra/loggers/empty_logger.dart';

abstract class LoggerService {
  void logI(String serviceName, String message);
  void logW(String serviceName, String message);
  void logE(String serviceName, String message);
}

Future<LoggerService> logger() async {
  if (!kReleaseMode) {
    return ConsoleLogger();
  } else {
    return EmptyLogger();
  }
}
