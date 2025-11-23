// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import '../types/download_configs.dart';

final defaultDownloadExistCheckerProvider = Provider<DownloadExistChecker>(
  (ref) => const FileSystemDownloadExistChecker(),
);

final defaultDirectoryExistCheckerProvider = Provider<DirectoryExistChecker>(
  (ref) => const FileSystemDirectoryExistChecker(),
);

class FileSystemDownloadExistChecker implements DownloadExistChecker {
  const FileSystemDownloadExistChecker();

  @override
  bool exists(String filename, String path) {
    final filePath = join(path, filename);

    return File(filePath).existsSync();
  }
}

class FileSystemDirectoryExistChecker implements DirectoryExistChecker {
  const FileSystemDirectoryExistChecker();

  @override
  bool exists(String path) {
    return Directory(path).existsSync();
  }
}
