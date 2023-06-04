// empty logger that log nothing on release mode

// Project imports:
import 'package:boorusama/core/loggers/loggers.dart';

class EmptyLogger implements LoggerService {
  @override
  void logE(String serviceName, String message) {}

  @override
  void logI(String serviceName, String message) {}

  @override
  void logW(String serviceName, String message) {}

  @override
  void log(String serviceName, String message, {LogLevel? level}) {}
}
