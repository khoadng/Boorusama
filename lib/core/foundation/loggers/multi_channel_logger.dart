// Project imports:
import 'logger.dart';

class MultiChannelLogger implements Logger {
  MultiChannelLogger({
    required this.loggers,
  });

  final List<Logger> loggers;

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
