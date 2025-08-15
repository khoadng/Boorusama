// Project imports:
import 'logger.dart';

typedef LogData = ({
  DateTime dateTime,
  String serviceName,
  String message,
  LogLevel level,
});

class AppLogger implements Logger {
  final List<LogData> _logs = [];

  @override
  String getDebugName() => 'App Logger';

  @override
  void error(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.error,
      ),
    );
  }

  @override
  void info(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.info,
      ),
    );
  }

  @override
  void warn(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.warning,
      ),
    );
  }

  @override
  void verbose(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.verbose,
      ),
    );
  }

  @override
  void debug(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.debug,
      ),
    );
  }

  List<LogData> get logs => _logs;

  @override
  String dump() {
    final buffer = StringBuffer();
    for (final log in logs) {
      buffer.write('[${log.dateTime}][${log.serviceName}]: ${log.message}\n');
    }
    return buffer.toString();
  }

  @override
  void clearLogsAtOrBelow(LogLevel level) {
    _logs.removeWhere((log) => log.level.priority <= level.priority);
  }
}
