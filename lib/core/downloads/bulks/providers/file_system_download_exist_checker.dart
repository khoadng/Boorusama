// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path/path.dart';

// Project imports:
import '../types/download_configs.dart';

class FileSystemDownloadExistChecker implements DownloadExistChecker {
  const FileSystemDownloadExistChecker();

  @override
  bool exists(String filename, String path) {
    final filePath = join(path, filename);

    return File(filePath).existsSync();
  }
}
