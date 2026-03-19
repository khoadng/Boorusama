// Package imports:
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../foundation/filesystem.dart';
import '../../foundation/loggers.dart';
import '../downloads/path/types.dart';
import 'types.dart';

Future<WriteLogStatus> writeLogs(
  AppFileSystem fs,
  List<LogData> logs,
) async => switch (await tryGetDownloadDirectory(fs)) {
  DownloadDirectoryFailure(:final message) => WriteLogFailure(
    message ?? 'Failed to get download directory',
  ),
  DownloadDirectorySuccess(:final path) => WriteLogSuccess(
    await writeDebugLogsToFilePath(fs, path, logs),
  ),
};

Future<String> writeDebugLogsToFilePath(
  AppFileSystem fs,
  String directoryPath,
  List<LogData> logs,
) async {
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final filePath = p.join(directoryPath, 'boorusama_logs_$timestamp.txt');
  final buffer = StringBuffer();
  for (final log in logs) {
    buffer.write(
      '[${log.dateTime}][${log.serviceName}]: ${log.message}\n',
    );
  }
  await fs.writeString(filePath, buffer.toString());
  return filePath;
}
