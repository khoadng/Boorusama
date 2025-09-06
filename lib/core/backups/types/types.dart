// Package imports:
import 'package:version/version.dart';

class ExportDataPayload {
  const ExportDataPayload({
    required this.version,
    required this.exportDate,
    required this.data,
    required this.exportVersion,
  });

  const ExportDataPayload.legacy({
    required this.data,
  }) : version = 1,
       exportDate = null,
       exportVersion = null;

  final int version;
  final DateTime? exportDate;
  final Version? exportVersion;
  final List<dynamic> data;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportVersion': ?exportVersion?.toString(),
    'date': ?exportDate?.toIso8601String(),
    'data': data,
  };
}

class InvalidBackupFormatException implements Exception {
  const InvalidBackupFormatException();
}
