// Project imports:
import 'logger.dart';

class MultiChannelLogger implements Logger {
  MultiChannelLogger({
    required this.loggers,
  });

  final List<Logger> loggers;

  @override
  void error(String serviceName, String message) {
    for (final logger in loggers) {
      logger.error(serviceName, message);
    }
  }

  @override
  void info(String serviceName, String message) {
    for (final logger in loggers) {
      logger.info(serviceName, message);
    }
  }

  @override
  void warn(String serviceName, String message) {
    for (final logger in loggers) {
      logger.warn(serviceName, message);
    }
  }
}
