// Dart imports:
import 'dart:io';

// Package imports:
import 'package:extended_image/extended_image.dart';

// Project imports:
import '../path.dart';

class DirectorySizeInfo {
  DirectorySizeInfo({
    required this.size,
    required this.fileCount,
    required this.directoryCount,
  });
  final int size;
  final int fileCount;
  final int directoryCount;

  static DirectorySizeInfo zero = DirectorySizeInfo(
    directoryCount: 0,
    fileCount: 0,
    size: 0,
  );
}

Future<DirectorySizeInfo> getDirectorySize(Directory dir) async {
  var size = 0;
  var fileCount = 0;
  var directoryCount = 0;

  try {
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is Directory) {
        final subDirSizeInfo = await getDirectorySize(entity);
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
  final cacheDir = await getAppTemporaryDirectory();
  return getDirectorySize(cacheDir);
}

Future<DirectorySizeInfo> getImageCacheSize() async {
  final cacheDir = await getTemporaryDirectory();
  final path = join(cacheDir.path, cacheImageFolderName);
  final imageCacheDir = Directory(path);
  return getDirectorySize(imageCacheDir);
}

Future<void> clearCache() async {
  final cacheDir = await getAppTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}

Future<bool> clearImageCache() async {
  final success = await clearDiskCachedImages();

  return success;
}
