// Package imports:
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../../../foundation/filesystem.dart';

const _kChecksumHeader = 'X-File-Checksum';

Future<shelf.Response> createDbStreamResponse({
  required AppFileSystem fs,
  required String filePath,
  required String fileName,
  String contentType = 'application/octet-stream',
  String checksumHeader = _kChecksumHeader,
}) async {
  if (!fs.fileExistsSync(filePath)) {
    return shelf.Response.notFound('Database file not found');
  }

  // Calculate checksum by consuming the file stream.
  final hash = await sha256.bind(fs.openRead(filePath)).single;
  final checksum = hash.toString();

  // Reopen file stream since the previous stream was consumed.
  final fileStream = fs.openRead(filePath);

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
  required AppFileSystem fs,
  required Dio dio,
  required String url,
  required String filePath,
  String checksumHeader = _kChecksumHeader,
}) async {
  final tempFilePath = '$filePath.tmp';
  final sink = await fs.openWrite(tempFilePath);

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

  final checksum = await computeFileChecksum(fs: fs, filePath: tempFilePath);
  if (checksum != expectedChecksum) {
    if (fs.fileExistsSync(tempFilePath)) {
      await fs.deleteFile(tempFilePath);
    }
    throw Exception('Database file is corrupted');
  }

  if (fs.fileExistsSync(filePath)) {
    await fs.deleteFile(filePath);
  }

  await fs.renameFile(tempFilePath, filePath);
}

Future<String> computeFileChecksum({
  required AppFileSystem fs,
  required String filePath,
}) async {
  final digest = await sha256.bind(fs.openRead(filePath)).single;
  return digest.toString();
}
