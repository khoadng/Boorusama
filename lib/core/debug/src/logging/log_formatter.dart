import '../types/log_data.dart';

String formatLogEntry(LogData log) =>
    '[${log.dateTime}][${log.serviceName}]: ${log.message}';

String formatLogs(List<LogData> logs) {
  final buffer = StringBuffer();
  if (logs.any((log) => log.sensitiveMessage != null)) {
    buffer.writeln('SENSITIVE DETAILS INCLUDED — may contain credentials.');
  }
  for (final log in logs) {
    buffer.writeln(formatLogEntry(log));
  }
  return buffer.toString();
}
