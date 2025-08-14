enum LogLevel {
  info,
  warning,
  error,
  verbose,
  debug,
}

abstract class Logger {
  void info(String serviceName, String message);
  void warn(String serviceName, String message);
  void error(String serviceName, String message);
  void verbose(String serviceName, String message);
  void debug(String serviceName, String message);

  String dump();
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
      case LogLevel.verbose:
        verbose(serviceName, message);
      case LogLevel.debug:
        debug(serviceName, message);
      case LogLevel.info:
      case null:
        info(serviceName, message);
    }
  }

  void debugBoot(String message) {
    debug('Boot', message);
  }
}
