// Project imports:
import 'package:boorusama/core/infra/loggers.dart';

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

  List<LogData> get logs => _logs;
}
