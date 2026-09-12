enum LogLevel {
  debug(0),
  verbose(1),
  info(2),
  warning(3),
  error(4);

  const LogLevel(this.priority);
  final int priority;

  bool shouldLog(LogLevel threshold) => priority >= threshold.priority;
}

/// Messages must contain safe diagnostic text. Supply raw server bodies,
/// exceptions or credential-bearing URLs only as `sensitiveMessage` arguments;
/// the application controls how those details are displayed and exported.
abstract class Logger {
  String getDebugName();

  void info(String serviceName, String message, {String? sensitiveMessage});
  void warn(String serviceName, String message, {String? sensitiveMessage});
  void error(String serviceName, String message, {String? sensitiveMessage});
  void verbose(String serviceName, String message, {String? sensitiveMessage});
  void debug(String serviceName, String message, {String? sensitiveMessage});
}

extension LoggerX on Logger {
  void log(
    String serviceName,
    String message, {
    LogLevel? level,
    String? sensitiveMessage,
  }) {
    switch (level) {
      case LogLevel.warning:
        warn(serviceName, message, sensitiveMessage: sensitiveMessage);
      case LogLevel.error:
        error(serviceName, message, sensitiveMessage: sensitiveMessage);
      case LogLevel.verbose:
        verbose(serviceName, message, sensitiveMessage: sensitiveMessage);
      case LogLevel.debug:
        debug(serviceName, message, sensitiveMessage: sensitiveMessage);
      case LogLevel.info:
      case null:
        info(serviceName, message, sensitiveMessage: sensitiveMessage);
    }
  }

  void debugBoot(String message) {
    debug('Boot', message);
  }
}
