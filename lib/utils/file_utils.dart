// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path_provider/path_provider.dart';

class DirectorySizeInfo {
  final int size;
  final int fileCount;
  final int directoryCount;

  DirectorySizeInfo({
    required this.size,
    required this.fileCount,
    required this.directoryCount,
  });

  static DirectorySizeInfo zero =
      DirectorySizeInfo(directoryCount: 0, fileCount: 0, size: 0);
}

Future<DirectorySizeInfo> getDirectorySize(Directory dir) async {
  int size = 0;
  int fileCount = 0;
  int directoryCount = 0;

  try {
    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is Directory) {
        var subDirSizeInfo = await getDirectorySize(entity);
        size += subDirSizeInfo.size;
        fileCount += subDirSizeInfo.fileCount;
        directoryCount += subDirSizeInfo.directoryCount + 1;
      } else if (entity is File) {
        size += await entity.length();
        fileCount++;
      }
    }
  } catch (e) {
    // print(e.toString());
  }

  return DirectorySizeInfo(
    size: size,
    fileCount: fileCount,
    directoryCount: directoryCount,
  );
}

Future<DirectorySizeInfo> getCacheSize() async {
  final cacheDir = await getTemporaryDirectory();
  return getDirectorySize(cacheDir);
}

Future<void> clearCache() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}
