import '../../../../foundation/loggers/logger.dart';

class LogData {
  const LogData({
    required this.dateTime,
    required this.serviceName,
    required this.safeMessage,
    required this.level,
    this.sensitiveMessage,
  });

  final DateTime dateTime;
  final String serviceName;
  final String safeMessage;
  final String? sensitiveMessage;
  final LogLevel level;

  String get message => sensitiveMessage ?? safeMessage;

  LogData withoutSensitiveDetails() => LogData(
    dateTime: dateTime,
    serviceName: serviceName,
    safeMessage: safeMessage,
    level: level,
  );
}
