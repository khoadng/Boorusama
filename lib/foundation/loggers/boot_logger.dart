// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';

typedef BootLogData = ({
  DateTime dateTime,
  String message,
  LogLevel level,
});

class BootLogger implements LoggerService {
  final List<BootLogData> _logs = [];

  @override
  void logE(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        message: message,
        level: LogLevel.error,
      ),
    );
  }

  @override
  void logI(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        message: message,
        level: LogLevel.info,
      ),
    );
  }

  @override
  void logW(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        message: message,
        level: LogLevel.warning,
      ),
    );
  }

  @override
  void log(
    String serviceName,
    String message, {
    LogLevel? level,
  }) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        message: message,
        level: level ?? LogLevel.info
      ),
    );
  }

  List<BootLogData> get logs => _logs;

  void l(String message) {
    log('Boot', message);
  }

  String dump() {
    final buffer = StringBuffer();
    for (final log in logs) {
      buffer.write('[${log.dateTime}]: ${log.message}\n');
    }
    return buffer.toString();
  }
}
