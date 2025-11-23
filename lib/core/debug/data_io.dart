// Dart imports:
import 'dart:io';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../foundation/loggers.dart';
import '../downloads/path/types.dart';
import 'types.dart';

Future<WriteLogStatus> writeLogs(
  List<LogData> logs,
) async => switch (await tryGetDownloadDirectory()) {
  DownloadDirectoryFailure(:final message) => WriteLogFailure(
    message ?? 'Failed to get download directory',
  ),
  DownloadDirectorySuccess(:final directory) => WriteLogSuccess(
    await writeDebugLogsToFilePath(directory, logs),
  ),
};

Future<String> writeDebugLogsToFilePath(
  Directory directory,
  List<LogData> logs,
) async {
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final file = File('${directory.path}/boorusama_logs_$timestamp.txt');
  final buffer = StringBuffer();
  for (final log in logs) {
    buffer.write(
      '[${log.dateTime}][${log.serviceName}]: ${log.message}\n',
    );
  }
  await file.writeAsString(buffer.toString());
  return file.path;
}
