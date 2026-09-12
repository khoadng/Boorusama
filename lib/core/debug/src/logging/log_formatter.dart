import '../types/log_data.dart';

String formatLogEntry(LogData log) =>
    '[${log.dateTime}][${log.serviceName}]: ${log.message}';

String formatLogs(
  List<LogData> logs, {
  Map<String, String> context = const {},
}) {
  final buffer = StringBuffer();
  if (logs.any((log) => log.sensitiveMessage != null)) {
    buffer.writeln('SENSITIVE DETAILS INCLUDED — may contain credentials.');
  }
  if (context.isNotEmpty) {
    buffer.writeln('Boorusama diagnostic context');
    for (final entry in context.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    buffer.writeln();
  }
  for (final log in logs) {
    buffer.writeln(formatLogEntry(log));
  }
  return buffer.toString();
}
