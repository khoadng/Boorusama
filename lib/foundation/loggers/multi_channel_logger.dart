// Project imports:
import 'logger.dart';

class MultiChannelLogger implements Logger {
  MultiChannelLogger({
    required this.loggers,
  });

  final List<Logger> loggers;

  @override
  String getDebugName() => 'Multi Channel Logger';

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

  @override
  void verbose(String serviceName, String message) {
    for (final logger in loggers) {
      logger.verbose(serviceName, message);
    }
  }

  @override
  void debug(String serviceName, String message) {
    for (final logger in loggers) {
      logger.debug(serviceName, message);
    }
  }
}
