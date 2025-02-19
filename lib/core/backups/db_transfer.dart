// Dart imports:
import 'dart:io';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shelf/shelf.dart' as shelf;

const _kChecksumHeader = 'X-File-Checksum';

Future<shelf.Response> createDbStreamResponse({
  required String filePath,
  required String fileName,
  String contentType = 'application/octet-stream',
  String checksumHeader = _kChecksumHeader,
}) async {
  final file = File(filePath);

  if (!file.existsSync()) {
    return shelf.Response.notFound('Database file not found');
  }

  // Calculate checksum by consuming the file stream.
  final hash = await sha256.bind(file.openRead()).single;
  final checksum = hash.toString();

  // Reopen file stream since the previous stream was consumed.
  final fileStream = file.openRead();

  return shelf.Response.ok(
    fileStream,
    headers: {
      'Content-Type': contentType,
      'Content-Disposition': 'attachment; filename="$fileName"',
      checksumHeader: checksum,
    },
  );
}

Future<void> downloadAndReplaceDb({
  required Dio dio,
  required String url,
  required String filePath,
  String checksumHeader = _kChecksumHeader,
}) async {
  final tempFilePath = '$filePath.tmp';
  final tempFile = File(tempFilePath);
  final sink = tempFile.openWrite();

  final response = await dio.get(
    url,
    options: Options(responseType: ResponseType.stream),
  );

  // Retrieve expected checksum from headers.
  final expectedChecksum = response.headers.value(checksumHeader);
  if (expectedChecksum == null) {
    throw Exception('No checksum provided in header.');
  }

  await sink.addStream(response.data.stream.cast<List<int>>());
  await sink.close();

  final checksum = await computeFileChecksum(tempFile);
  if (checksum != expectedChecksum) {
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    throw Exception('Database file is corrupted');
  }

  final currentDbFile = File(filePath);
  if (currentDbFile.existsSync()) {
    await currentDbFile.delete();
  }

  await tempFile.rename(filePath);
}

Future<String> computeFileChecksum(File file) async {
  final digest = await sha256.bind(file.openRead()).single;
  return digest.toString();
}
