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
  void error(String serviceName, String message, {String? sensitiveMessage}) {
    for (final logger in loggers) {
      logger.error(
        serviceName,
        message,
        sensitiveMessage: sensitiveMessage,
      );
    }
  }

  @override
  void info(String serviceName, String message, {String? sensitiveMessage}) {
    for (final logger in loggers) {
      logger.info(
        serviceName,
        message,
        sensitiveMessage: sensitiveMessage,
      );
    }
  }

  @override
  void warn(String serviceName, String message, {String? sensitiveMessage}) {
    for (final logger in loggers) {
      logger.warn(
        serviceName,
        message,
        sensitiveMessage: sensitiveMessage,
      );
    }
  }

  @override
  void verbose(String serviceName, String message, {String? sensitiveMessage}) {
    for (final logger in loggers) {
      logger.verbose(
        serviceName,
        message,
        sensitiveMessage: sensitiveMessage,
      );
    }
  }

  @override
  void debug(String serviceName, String message, {String? sensitiveMessage}) {
    for (final logger in loggers) {
      logger.debug(
        serviceName,
        message,
        sensitiveMessage: sensitiveMessage,
      );
    }
  }
}
