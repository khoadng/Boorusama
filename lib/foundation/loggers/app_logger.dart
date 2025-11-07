// Project imports:
import 'logger.dart';

typedef LogData = ({
  DateTime dateTime,
  String serviceName,
  String message,
  LogLevel level,
});

class AppLogger implements Logger {
  AppLogger({LogLevel initialLevel = LogLevel.info})
    : _currentLevel = initialLevel;

  final List<LogData> _logs = [];
  LogLevel _currentLevel;

  void updateLevel(LogLevel newLevel) {
    _currentLevel = newLevel;
  }

  LogLevel get currentLevel => _currentLevel;

  @override
  String getDebugName() => 'App Logger';

  @override
  void error(String serviceName, String message) {
    if (LogLevel.error.shouldLog(_currentLevel)) {
      _logs.add(
        (
          dateTime: DateTime.now(),
          serviceName: serviceName,
          message: message,
          level: LogLevel.error,
        ),
      );
    }
  }

  @override
  void info(String serviceName, String message) {
    if (LogLevel.info.shouldLog(_currentLevel)) {
      _logs.add(
        (
          dateTime: DateTime.now(),
          serviceName: serviceName,
          message: message,
          level: LogLevel.info,
        ),
      );
    }
  }

  @override
  void warn(String serviceName, String message) {
    if (LogLevel.warning.shouldLog(_currentLevel)) {
      _logs.add(
        (
          dateTime: DateTime.now(),
          serviceName: serviceName,
          message: message,
          level: LogLevel.warning,
        ),
      );
    }
  }

  @override
  void verbose(String serviceName, String message) {
    if (LogLevel.verbose.shouldLog(_currentLevel)) {
      _logs.add(
        (
          dateTime: DateTime.now(),
          serviceName: serviceName,
          message: message,
          level: LogLevel.verbose,
        ),
      );
    }
  }

  @override
  void debug(String serviceName, String message) {
    if (LogLevel.debug.shouldLog(_currentLevel)) {
      _logs.add(
        (
          dateTime: DateTime.now(),
          serviceName: serviceName,
          message: message,
          level: LogLevel.debug,
        ),
      );
    }
  }

  List<LogData> get logs => _logs;

  String dump() {
    final buffer = StringBuffer();
    for (final log in logs) {
      buffer.write('[${log.dateTime}][${log.serviceName}]: ${log.message}\n');
    }
    return buffer.toString();
  }

  void clearLogsAtOrBelow(LogLevel level) {
    _logs.removeWhere((log) => log.level.priority <= level.priority);
  }
}
