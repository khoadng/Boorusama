// ignore_for_file: avoid_print

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'logger.dart';

class ConsoleLogger extends LoggerService {
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  // compose log message
  String _composeMessage(String serviceName, String message) {
    return '${_formatDateTime(DateTime.now())} -> $serviceName -> $message';
  }

  @override
  void logI(String serviceName, String message) {
    print(_composeMessage(serviceName, message));
  }

  @override
  void logW(String serviceName, String message) {
    print(_composeMessage(serviceName, message));
  }

  @override
  void logE(String serviceName, String message) {
    print(_composeMessage(serviceName, message));
  }
}
