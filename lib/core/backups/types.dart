import 'package:version/version.dart';

sealed class ExportError {
  const ExportError._(this.message);

  final String message;

  @override
  String toString() => message;
}

final class StoragePermissionDenied extends ExportError {
  const StoragePermissionDenied()
      : super._('Permission to access storage denied');
}

final class JsonSerializationError extends ExportError {
  const JsonSerializationError({
    required this.error,
    required this.stackTrace,
  }) : super._('Error while serializing data to JSON');

  final Object error;
  final StackTrace stackTrace;
}

final class JsonEncodingError extends ExportError {
  const JsonEncodingError({
    required this.error,
    required this.stackTrace,
  }) : super._('Error while encoding JSON');

  final Object error;
  final StackTrace stackTrace;
}

final class DataExportError extends ExportError {
  const DataExportError({
    required this.error,
    required this.stackTrace,
  }) : super._('Error while exporting data');

  final Object error;
  final StackTrace stackTrace;
}

final class DataExportNotPermitted extends ExportError {
  const DataExportNotPermitted({
    required this.error,
    required this.stackTrace,
  }) : super._('Cannot export data to this location');

  final Object error;
  final StackTrace stackTrace;
}

sealed class ImportError {
  const ImportError._(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ImportErrorEmpty extends ImportError {
  const ImportErrorEmpty() : super._('Data is empty');
}

final class ImportInvalidJson extends ImportError {
  const ImportInvalidJson() : super._('Invalid backup format');
}

final class ImportInvalidJsonField extends ImportError {
  const ImportInvalidJsonField()
      : super._(
            'Missing required fields or invalid field type, are you sure this is a valid backup file?');
}

class ExportDataPayload {
  ExportDataPayload({
    required this.version,
    required this.exportDate,
    required this.data,
    required this.exportVersion,
  });

  final int version;
  final DateTime exportDate;
  final Version? exportVersion;
  final List<dynamic> data;

  Map<String, dynamic> toJson() => {
        'version': version,
        if (exportVersion != null) 'exportVersion': exportVersion.toString(),
        'date': exportDate.toIso8601String(),
        'data': data,
      };
}
