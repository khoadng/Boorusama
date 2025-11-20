// Dart imports:
import 'dart:io';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../foundation/loggers.dart';

Future<File> writeDebugLogsToFile(
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
  return file;
}

extension FormatX on LogData {
  String format() {
    final msg = tryDecodeFullUri(message).getOrElse(() => message);

    return msg;
  }
}
