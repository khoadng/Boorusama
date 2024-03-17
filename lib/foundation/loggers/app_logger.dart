// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';

typedef LogData = ({
  DateTime dateTime,
  String serviceName,
  String message,
  LogLevel level,
});

class AppLogger implements LoggerService {
  final List<LogData> _logs = [];

  @override
  void logE(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.error
      ),
    );
  }

  @override
  void logI(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.info
      ),
    );
  }

  @override
  void logW(String serviceName, String message) {
    _logs.add(
      (
        dateTime: DateTime.now(),
        serviceName: serviceName,
        message: message,
        level: LogLevel.warning
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
        serviceName: serviceName,
        message: message,
        level: level ?? LogLevel.info
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
