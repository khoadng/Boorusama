// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/functional.dart';
import 'booru_config.dart';

sealed class BooruConfigExportError {
  const BooruConfigExportError._(this.message);

  final String message;

  @override
  String toString() => message;
}

final class StoragePermissionDenied extends BooruConfigExportError {
  const StoragePermissionDenied()
      : super._('Permission to access storage denied');
}

final class JsonSerializationError extends BooruConfigExportError {
  const JsonSerializationError({
    required this.error,
    required this.stackTrace,
  }) : super._('Error while serializing data to JSON');

  final Object error;
  final StackTrace stackTrace;
}

final class JsonEncodingError extends BooruConfigExportError {
  const JsonEncodingError({
    required this.error,
    required this.stackTrace,
  }) : super._('Error while encoding JSON');

  final Object error;
  final StackTrace stackTrace;
}

final class ExportError extends BooruConfigExportError {
  const ExportError({
    required this.error,
    required this.stackTrace,
  }) : super._('Error while exporting data');

  final Object error;
  final StackTrace stackTrace;
}

sealed class BooruConfigImportError {
  const BooruConfigImportError._(this.message);

  final String message;

  @override
  String toString() => message;
}

final class BooruConfigImportErrorEmpty extends BooruConfigImportError {
  const BooruConfigImportErrorEmpty() : super._('No profile found');
}

final class BooruConfigImportErrorInvalid extends BooruConfigImportError {
  const BooruConfigImportErrorInvalid()
      : super._('Invalid profile found in the file');
}

final class InvalidJson extends BooruConfigImportError {
  const InvalidJson() : super._('Invalid JSON found in the file');
}

final class InvalidJsonField extends BooruConfigImportError {
  const InvalidJsonField()
      : super._(
            'Invalid JSON field found in the file, missing required fields or invalid field type');
}

class BooruConfigExportData {
  BooruConfigExportData({
    required this.version,
    required this.exportDate,
    required this.data,
  });

  final int version;
  final DateTime exportDate;
  final List<BooruConfig> data;

  Map<String, dynamic> toJson() => {
        'version': version,
        'data': data.map((e) => e.toJson()).toList(),
        'date': exportDate.toIso8601String(),
      };
}

const kExporterImporterVersion = 1;

class BooruConfigIOHandler {
  BooruConfigIOHandler({
    required this.permissionChecker,
    required this.permissionRequester,
    required this.exporter,
    required this.importer,
    required this.version,
  });

  static void exportToClipboard({
    required List<BooruConfig> configs,
    void Function()? onSucceed,
    void Function(String error)? onError,
  }) =>
      tryEncodeConfigData(
        version: kExporterImporterVersion,
        exportDate: DateTime.now(),
        configs: configs,
      ).fold(
        (l) => onError?.call(l.toString()),
        (r) => Clipboard.setData(ClipboardData(text: r))
            .then((value) => onSucceed?.call())
            .catchError((e, st) => onError?.call(e.toString())),
      );

  static Future<Either<BooruConfigImportError, BooruConfigExportData>>
      importFromClipboard() async {
    final data = await Clipboard.getData('text/plain');

    final jsonString = data?.text;
    if (jsonString == null || jsonString.isEmpty) {
      return left(const BooruConfigImportErrorEmpty());
    }

    return tryDecodeConfigData(data: jsonString);
  }

  factory BooruConfigIOHandler.file({
    required DeviceInfo deviceInfo,
  }) =>
      BooruConfigIOHandler(
        version: kExporterImporterVersion,
        permissionChecker: () => checkMediaPermissions(deviceInfo),
        permissionRequester: () => requestMediaPermissions(deviceInfo),
        exporter: (path, data) async {
          final dir = Directory(path);
          final date = DateFormat('yyyy.MM.dd.mm.ss').format(DateTime.now());
          final file = File(join(dir.path, 'boorusama_profiles_$date.json'));

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

  TaskEither<BooruConfigExportError, Unit> export({
    required List<BooruConfig> configs,
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
            final jsonString = await $(tryEncodeConfigData(
              version: version,
              exportDate: DateTime.now(),
              configs: configs,
            ).toTaskEither());

            await exporter(path, jsonString);
          } catch (e, st) {
            throw ExportError(error: e, stackTrace: st);
          }

          return unit;
        },
      );

  TaskEither<BooruConfigImportError, BooruConfigExportData> import({
    required String path,
  }) =>
      TaskEither.Do(
        ($) async {
          final json = await importer(path);
          final data =
              $(TaskEither.fromEither(tryDecodeConfigData(data: json)));

          return data;
        },
      );
}

Either<BooruConfigExportError, String> tryEncodeConfigData({
  required int version,
  required DateTime exportDate,
  required List<BooruConfig> configs,
}) =>
    Either.Do(($) {
      try {
        final data = BooruConfigExportData(
          version: version,
          exportDate: DateTime.now(),
          data: configs,
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

Either<BooruConfigImportError, BooruConfigExportData> tryDecodeConfigData({
  required String data,
}) =>
    Either.Do(($) {
      final json = $(tryDecodeJson<Map<String, dynamic>>(data)
          .mapLeft((a) => const InvalidJson()));

      final version = $(Either.tryCatch(
        () => json['version'] as int,
        (o, s) => const InvalidJsonField(),
      ));

      final date = $(Either.tryCatch(
        () => DateTime.parse(json['date'] as String),
        (o, s) => const InvalidJsonField(),
      ));

      final payload = $(Either.tryCatch(
        () => json['data'] as List<dynamic>,
        (o, s) => const InvalidJsonField(),
      ));

      final booruConfigs = $(Either.tryCatch(
        () => payload.map((e) => BooruConfig.fromJson(e)).toList(),
        (o, s) => const InvalidJsonField(),
      ));

      if (booruConfigs.isEmpty) {
        return $(left(const BooruConfigImportErrorEmpty()));
      }

      return BooruConfigExportData(
        version: version,
        exportDate: date,
        data: booruConfigs,
      );
    });
