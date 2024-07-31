// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:version/version.dart';

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

class DataIOHandler {
  DataIOHandler({
    required this.permissionChecker,
    required this.permissionRequester,
    required this.exporter,
    required this.importer,
    required this.version,
    required this.exportVersion,
  });

  factory DataIOHandler.file({
    required DeviceInfo deviceInfo,
    required String prefixName,
    required int version,
    required Version? exportVersion,
  }) =>
      DataIOHandler(
        version: version,
        exportVersion: exportVersion,
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
  final Version? exportVersion;

  TaskEither<ExportError, Unit> export({
    required List<dynamic> data,
    required String path,
  }) =>
      TaskEither.Do(
        ($) async {
          final status = await permissionChecker();

          if (status != PermissionStatus.granted) {
            final status = await permissionRequester();

            if (status != PermissionStatus.granted) {
              return $(TaskEither.left(const StoragePermissionDenied()));
            }
          }

          final jsonString = await $(tryEncodeData(
            version: version,
            exportDate: DateTime.now(),
            exportVersion: exportVersion,
            payload: data,
          ).toTaskEither());

          return await $(TaskEither.tryCatch(
            () async {
              await exporter(path, jsonString);

              return unit;
            },
            (e, st) {
              if (e is PathAccessException) {
                return DataExportNotPermitted(
                  error: e,
                  stackTrace: st,
                );
              } else {
                return DataExportError(
                  error: e,
                  stackTrace: st,
                );
              }
            },
          ));
        },
      );

  TaskEither<ImportError, ExportDataPayload> import({
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

Either<ExportError, String> tryEncodeData({
  required int version,
  required DateTime exportDate,
  required Version? exportVersion,
  required List<dynamic> payload,
}) =>
    Either.Do(($) {
      try {
        final data = ExportDataPayload(
          version: version,
          exportDate: exportDate,
          exportVersion: exportVersion,
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

Either<ImportError, ExportDataPayload> tryDecodeData({
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

      final exportVersion = $(Either.tryCatch(
        () => json['exportVersion'] != null
            ? Version.parse(json['exportVersion'] as String)
            : null,
        (o, s) => const ImportInvalidJsonField(),
      ));

      final payload = $(Either.tryCatch(
        () => json['data'] as List<dynamic>,
        (o, s) => const ImportInvalidJsonField(),
      ));

      return ExportDataPayload(
        version: version,
        exportDate: date,
        exportVersion: exportVersion,
        data: payload,
      );
    });
