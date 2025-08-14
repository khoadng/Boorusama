// Project imports:
import 'logger.dart';

typedef BootLogData = ({DateTime dateTime, String message, LogLevel level});

class BootLogger implements Logger {
  final List<BootLogData> _logs = [];

  @override
  void error(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
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
        message: message,
        level: LogLevel.warning,
      ),
    );
  }

  List<BootLogData> get logs => _logs;

  void l(String message) {
    info('Boot', message);
  }

  String dump() {
    final buffer = StringBuffer();
    for (final log in logs) {
      buffer.write('[${log.dateTime}]: ${log.message}\n');
    }
    return buffer.toString();
  }
}
