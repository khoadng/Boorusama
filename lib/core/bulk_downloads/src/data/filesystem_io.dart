// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import '../../../../foundation/filesystem.dart';
import '../types/download_configs.dart';

final defaultDownloadExistCheckerProvider = Provider<DownloadExistChecker>(
  (ref) => FileSystemDownloadExistChecker(
    ref.watch(appFileSystemProvider),
  ),
);

final defaultDirectoryExistCheckerProvider = Provider<DirectoryExistChecker>(
  (ref) => FileSystemDirectoryExistChecker(
    ref.watch(appFileSystemProvider),
  ),
);

class FileSystemDownloadExistChecker implements DownloadExistChecker {
  const FileSystemDownloadExistChecker(this.fs);

  final AppFileSystem fs;

  @override
  bool exists(String filename, String path) {
    final filePath = join(path, filename);

    return fs.fileExistsSync(filePath);
  }
}

class FileSystemDirectoryExistChecker implements DirectoryExistChecker {
  const FileSystemDirectoryExistChecker(this.fs);

  final AppFileSystem fs;

  @override
  bool exists(String path) {
    return fs.directoryExistsSync(path);
  }
}
