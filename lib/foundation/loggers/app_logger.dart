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

  List<LogData> get logs => _logs;

  String dump() {
    final buffer = StringBuffer();
    for (final log in logs) {
      buffer.write('[${log.dateTime}][${log.serviceName}]: ${log.message}\n');
    }
    return buffer.toString();
  }
}
