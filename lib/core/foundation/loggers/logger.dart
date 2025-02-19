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
