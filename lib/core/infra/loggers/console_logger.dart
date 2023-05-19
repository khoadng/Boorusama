// Dart imports:
import 'dart:developer' as developer;

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'logger.dart';

class ConsoleLogger extends LoggerService {
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd, hh:mm:ss').format(dateTime);
  }

  // compose log message
  String _composeMessage(String serviceName, String message) {
    return '\x1B[33m${_formatDateTime(DateTime.now())}\x1B[0m -> \x1B[35m$serviceName\x1B[0m -> \x1B[34m$message\x1B[0m';
  }

  @override
  void logI(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message));
  }

  @override
  void logW(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message));
  }

  @override
  void logE(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message));
  }
}
