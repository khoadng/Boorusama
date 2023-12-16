// Dart imports:
import 'dart:convert';
import 'dart:io';

// Project imports:
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/functional.dart';

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

sealed class DataImportError {
  const DataImportError._(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ImportErrorEmpty extends DataImportError {
  const ImportErrorEmpty() : super._('Data is empty');
}

final class ImportInvalidJson extends DataImportError {
  const ImportInvalidJson() : super._('Invalid backup format');
}

final class ImportInvalidJsonField extends DataImportError {
  const ImportInvalidJsonField()
      : super._('Missing required fields or invalid field type');
}

class ExportDataPayload {
  ExportDataPayload({
    required this.version,
    required this.exportDate,
    required this.data,
  });

  final int version;
  final DateTime exportDate;
  final List<dynamic> data;

  Map<String, dynamic> toJson() => {
        'version': version,
        'date': exportDate.toIso8601String(),
        'data': data,
      };
}

class DataIOHandler {
  DataIOHandler({
    required this.permissionChecker,
    required this.permissionRequester,
    required this.exporter,
    required this.importer,
    required this.version,
  });

  factory DataIOHandler.file({
    required DeviceInfo deviceInfo,
    required String prefixName,
    required int version,
  }) =>
      DataIOHandler(
        version: version,
        permissionChecker: () => checkMediaPermissions(deviceInfo),
        permissionRequester: () => requestMediaPermissions(deviceInfo),
        exporter: (path, data) async {
          final dir = Directory(path);
          final date = DateFormat('yyyy.MM.dd.mm.ss').format(DateTime.now());
          final file = File(join(dir.path, '${prefixName}_$date.json'));

          await file.writeAsString(data);
        },
        importer: (path) async {
          final file = File(path);
          final jsonString = await file.readAsString();

          return jsonString;
        },
      );

  final Future<PermissionStatus> Function() permissionChecker;
  final Future<PermissionStatus> Function() permissionRequester;
  final Future<void> Function(String path, String data) exporter;
  final Future<String> Function(String path) importer;
  final int version;

  TaskEither<DataExportError, Unit> export({
    required List<dynamic> data,
    required String path,
  }) =>
      TaskEither.Do(
        ($) async {
          final status = await permissionChecker();

          if (status != PermissionStatus.granted) {
            final status = await permissionRequester();

            if (status != PermissionStatus.granted) {
              throw const StoragePermissionDenied();
            }
          }

          try {
            final jsonString = await $(tryEncodeData(
              version: version,
              exportDate: DateTime.now(),
              payload: data,
            ).toTaskEither());

            await exporter(path, jsonString);
          } catch (e, st) {
            throw DataExportError(error: e, stackTrace: st);
          }

          return unit;
        },
      );

  TaskEither<DataImportError, ExportDataPayload> import({
    required String path,
  }) =>
      TaskEither.Do(
        ($) async {
          final json = await importer(path);
          final data = $(TaskEither.fromEither(tryDecodeData(data: json)));

          return data;
        },
      );
}

Either<DataExportError, String> tryEncodeData({
  required int version,
  required DateTime exportDate,
  required List<dynamic> payload,
}) =>
    Either.Do(($) {
      try {
        final data = ExportDataPayload(
          version: version,
          exportDate: DateTime.now(),
          data: payload,
        ).toJson();

        try {
          final jsonString = jsonEncode(data);
          return jsonString;
        } catch (e, st) {
          throw JsonEncodingError(error: e, stackTrace: st);
        }
      } catch (e, st) {
        throw JsonSerializationError(error: e, stackTrace: st);
      }
    });

Either<DataImportError, ExportDataPayload> tryDecodeData({
  required String data,
}) =>
    Either.Do(($) {
      final json = $(tryDecodeJson<Map<String, dynamic>>(data)
          .mapLeft((a) => const ImportInvalidJson()));

      final version = $(Either.tryCatch(
        () => json['version'] as int,
        (o, s) => const ImportInvalidJsonField(),
      ));

      final date = $(Either.tryCatch(
        () => DateTime.parse(json['date'] as String),
        (o, s) => const ImportInvalidJsonField(),
      ));

      final payload = $(Either.tryCatch(
        () => json['data'] as List<dynamic>,
        (o, s) => const ImportInvalidJsonField(),
      ));

      return ExportDataPayload(
        version: version,
        exportDate: date,
        data: payload,
      );
    });
