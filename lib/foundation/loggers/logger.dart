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

abstract class Logger {
  String getDebugName();

  void info(String serviceName, String message);
  void warn(String serviceName, String message);
  void error(String serviceName, String message);
  void verbose(String serviceName, String message);
  void debug(String serviceName, String message);

  String dump();
  void clearLogsAtOrBelow(LogLevel level);
}

class ThresholdLogger implements Logger {
  ThresholdLogger({
    required this.delegate,
    LogLevel initialLevel = LogLevel.info,
  }) : _currentLevel = initialLevel;

  final Logger delegate;
  LogLevel _currentLevel;

  // ignore: use_setters_to_change_properties
  void updateLevel(LogLevel newLevel) {
    _currentLevel = newLevel;
  }

  LogLevel get currentLevel => _currentLevel;

  @override
  String getDebugName() => delegate.getDebugName();

  @override
  void debug(String serviceName, String message) {
    if (LogLevel.debug.shouldLog(_currentLevel)) {
      delegate.debug(serviceName, message);
    }
  }

  @override
  void verbose(String serviceName, String message) {
    if (LogLevel.verbose.shouldLog(_currentLevel)) {
      delegate.verbose(serviceName, message);
    }
  }

  @override
  void info(String serviceName, String message) {
    if (LogLevel.info.shouldLog(_currentLevel)) {
      delegate.info(serviceName, message);
    }
  }

  @override
  void warn(String serviceName, String message) {
    if (LogLevel.warning.shouldLog(_currentLevel)) {
      delegate.warn(serviceName, message);
    }
  }

  @override
  void error(String serviceName, String message) {
    if (LogLevel.error.shouldLog(_currentLevel)) {
      delegate.error(serviceName, message);
    }
  }

  @override
  String dump() => delegate.dump();

  @override
  void clearLogsAtOrBelow(LogLevel level) {
    delegate.clearLogsAtOrBelow(level);
  }
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
