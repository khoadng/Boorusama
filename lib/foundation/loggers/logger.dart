enum LogLevel {
  info,
  warning,
  error,
}

abstract class Logger {
  void info(String serviceName, String message);
  void warn(String serviceName, String message);
  void error(String serviceName, String message);
}

extension LoggerX on Logger {
  void log(
    String serviceName,
    String message, {
    LogLevel? level,
  }) {
    switch (level) {
      case LogLevel.warning:
        warn(serviceName, message);
      case LogLevel.error:
        error(serviceName, message);
      case LogLevel.info:
      case null:
        info(serviceName, message);
    }
  }
}
