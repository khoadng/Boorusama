// Package imports:
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../../../foundation/filesystem.dart';
import '../types/log_data.dart';
import '../logging/log_formatter.dart';
import '../../../downloads/path/types.dart';
import '../types/write_log_status.dart';

Future<WriteLogStatus> writeLogs(
  AppFileSystem fs,
  List<LogData> logs, {
  Map<String, String> context = const {},
}) async => switch (await tryGetDownloadDirectory(fs)) {
  DownloadDirectoryFailure(:final message) => WriteLogFailure(
    message ?? 'Failed to get download directory',
  ),
  DownloadDirectorySuccess(:final path) => WriteLogSuccess(
    await writeDebugLogsToFilePath(fs, path, logs, context: context),
  ),
};

Future<String> writeDebugLogsToFilePath(
  AppFileSystem fs,
  String directoryPath,
  List<LogData> logs, {
  Map<String, String> context = const {},
}) async {
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final filePath = p.join(directoryPath, 'boorusama_logs_$timestamp.txt');
  await fs.writeString(filePath, formatLogs(logs, context: context));
  return filePath;
}
