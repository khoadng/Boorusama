// Project imports:
import 'package:boorusama/core/infra/loggers.dart';

class MultiChannelLogger implements LoggerService {
  MultiChannelLogger({
    required this.loggers,
  });

  final List<LoggerService> loggers;

  @override
  void logE(String serviceName, String message) {
    for (final logger in loggers) {
      logger.logE(serviceName, message);
    }
  }

  @override
  void logI(String serviceName, String message) {
    for (final logger in loggers) {
      logger.logI(serviceName, message);
    }
  }

  @override
  void logW(String serviceName, String message) {
    for (final logger in loggers) {
      logger.logW(serviceName, message);
    }
  }

  @override
  void log(
    String serviceName,
    String message, {
    LogLevel? level,
  }) {
    for (final logger in loggers) {
      logger.log(serviceName, message, level: level);
    }
  }
}
