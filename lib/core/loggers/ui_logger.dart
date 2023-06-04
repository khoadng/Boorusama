// Project imports:
import 'package:boorusama/core/loggers/loggers.dart';

typedef LogData = ({
  DateTime dateTime,
  String serviceName,
  String message,
});

class UILogger implements LoggerService {
  final List<LogData> _logs = [];

  @override
  void logE(String serviceName, String message) {
    _logs.add(
      (dateTime: DateTime.now(), serviceName: serviceName, message: message),
    );
  }

  @override
  void logI(String serviceName, String message) {
    _logs.add(
      (dateTime: DateTime.now(), serviceName: serviceName, message: message),
    );
  }

  @override
  void logW(String serviceName, String message) {
    _logs.add(
      (dateTime: DateTime.now(), serviceName: serviceName, message: message),
    );
  }

  @override
  void log(
    String serviceName,
    String message, {
    LogLevel? level,
  }) {
    _logs.add(
      (dateTime: DateTime.now(), serviceName: serviceName, message: message),
    );
  }

  List<LogData> get logs => _logs;
}
