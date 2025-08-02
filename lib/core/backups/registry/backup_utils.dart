// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:foundation/foundation.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../types.dart';

class BackupUtils {
  static TaskEither<ExportError, String> encodeJson(dynamic data) =>
      TaskEither.tryCatch(
        () async => jsonEncode(data),
        (e, st) => JsonEncodingError(error: e, stackTrace: st),
      );

  static TaskEither<ImportError, T> decodeJson<T>(
    String json,
    T Function(Map<String, dynamic>) factory,
  ) => TaskEither.tryCatch(
    () async {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return factory(map);
    },
    (e, st) => const ImportInvalidJson(),
  );

  static TaskEither<ImportError, List<T>> decodeJsonList<T>(
    String json,
    T Function(Map<String, dynamic>) factory,
  ) => TaskEither.tryCatch(
    () async {
      final list = jsonDecode(json) as List<dynamic>;
      return list.cast<Map<String, dynamic>>().map(factory).toList();
    },
    (e, st) => const ImportInvalidJson(),
  );

  static TaskEither<ExportError, Unit> writeFile(
    String path,
    String content,
  ) => TaskEither.tryCatch(
    () async {
      final file = File(path);
      await file.writeAsString(content);
      return unit;
    },
    (e, st) {
      if (e is PathAccessException) {
        return DataExportNotPermitted(error: e, stackTrace: st);
      }
      return DataExportError(error: e, stackTrace: st);
    },
  );

  static TaskEither<ImportError, String> readFile(String path) =>
      TaskEither.tryCatch(
        () async {
          final file = File(path);
          return file.readAsString();
        },
        (e, st) => const ImportInvalidJson(),
      );

  static Future<Response> streamFile(String path, String fileName) async {
    final file = File(path);

    if (!file.existsSync()) {
      return Response.notFound('File not found');
    }

    // Calculate checksum
    final hash = await sha256.bind(file.openRead()).single;
    final checksum = hash.toString();

    // Reopen file stream
    final fileStream = file.openRead();

    return Response.ok(
      fileStream,
      headers: {
        'Content-Type': 'application/octet-stream',
        'Content-Disposition': 'attachment; filename="$fileName"',
        'X-File-Checksum': checksum,
      },
    );
  }

  static Future<void> downloadFile(
    Dio dio,
    String url,
    String filePath, {
    String checksumHeader = 'X-File-Checksum',
  }) async {
    final tempFilePath = '$filePath.tmp';
    final tempFile = File(tempFilePath);
    final sink = tempFile.openWrite();

    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.stream),
    );

    // Retrieve expected checksum from headers
    final expectedChecksum = response.headers.value(checksumHeader);
    if (expectedChecksum == null) {
      throw Exception('No checksum provided in header.');
    }

    await sink.addStream(response.data.stream.cast<List<int>>());
    await sink.close();

    // Verify checksum
    final digest = await sha256.bind(tempFile.openRead()).single;
    final checksum = digest.toString();

    if (checksum != expectedChecksum) {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
      throw Exception('File is corrupted');
    }

    final currentFile = File(filePath);
    if (currentFile.existsSync()) {
      await currentFile.delete();
    }

    await tempFile.rename(filePath);
  }

  static TaskEither<ExportError, Unit> writeFileToDirectory(
    String directoryPath,
    String fileName,
    String content,
  ) => TaskEither.tryCatch(
    () async {
      final dir = Directory(directoryPath);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      final file = File(join(directoryPath, fileName));
      await file.writeAsString(content);
      return unit;
    },
    (e, st) {
      if (e is PathAccessException) {
        return DataExportNotPermitted(error: e, stackTrace: st);
      }
      return DataExportError(error: e, stackTrace: st);
    },
  );

  static Response jsonResponse(dynamic data) {
    final json = jsonEncode(data);
    return Response.ok(
      json,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
