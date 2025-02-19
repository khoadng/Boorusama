// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:version/version.dart';

// Project imports:
import 'types.dart';

class DataBackupConverter {
  DataBackupConverter({
    required this.version,
    required this.exportVersion,
  });

  final int version;
  final Version? exportVersion;

  Either<ExportError, String> tryEncode({
    required List<dynamic> payload,
  }) =>
      tryEncodeData(
        version: version,
        exportDate: DateTime.now(),
        exportVersion: exportVersion,
        payload: payload,
      );

  Either<ImportError, ExportDataPayload> tryDecode({
    required String data,
  }) =>
      tryDecodeData(
        data: data,
      );
}

Either<ExportError, String> tryEncodeData({
  required int version,
  required DateTime exportDate,
  required Version? exportVersion,
  required List<dynamic> payload,
}) =>
    Either.Do(($) {
      final data = ExportDataPayload(
        version: version,
        exportDate: exportDate,
        exportVersion: exportVersion,
        data: payload,
      ).toJson();

      return $(
        Either.tryCatch(
          () => jsonEncode(data),
          (e, st) => JsonEncodingError(error: e, stackTrace: st),
        ),
      );
    });

Either<ImportError, ExportDataPayload> tryDecodeData({
  required String data,
}) =>
    Either.Do(($) {
      final json = $(
        tryDecodeJson<Map<String, dynamic>>(data)
            .mapLeft((a) => const ImportInvalidJson()),
      );

      final version = $(
        Either.tryCatch(
          () => json['version'] as int,
          (o, s) => const ImportInvalidJsonField(),
        ),
      );

      final date = $(
        Either.tryCatch(
          () => DateTime.parse(json['date'] as String),
          (o, s) => const ImportInvalidJsonField(),
        ),
      );

      final exportVersion = $(
        Either.tryCatch(
          () => json['exportVersion'] != null
              ? Version.parse(json['exportVersion'] as String)
              : null,
          (o, s) => const ImportInvalidJsonField(),
        ),
      );

      final payload = $(
        Either.tryCatch(
          () => json['data'] as List<dynamic>,
          (o, s) => const ImportInvalidJsonField(),
        ),
      );

      return ExportDataPayload(
        version: version,
        exportDate: date,
        exportVersion: exportVersion,
        data: payload,
      );
    });
