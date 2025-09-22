// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:extended_image/extended_image.dart';

// Project imports:
import '../path.dart';
import '../platform.dart';

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
    if (isWindows()) {
      // On Windows, delete contents but keep the directory to avoid file lock issues
      try {
        await for (final entity in cacheDir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            // Silently ignore deletion errors for individual files/folders
          }
        }
      } catch (e) {
        // Silently ignore if we can't list directory contents
      }
    } else {
      // On other platforms, delete the entire directory
      cacheDir.deleteSync(recursive: true);
    }
  }
}

Future<bool> clearImageCache(ImageCacheManager? cacheManager) async {
  final success = await clearDiskCachedImages();

  if (cacheManager != null) {
    try {
      cacheManager.invalidateCacheDirectory();
    } catch (e) {
      // ignore errors
    }
  }

  return success;
}

class DiskSpaceInfo {
  DiskSpaceInfo({
    required this.freeSpace,
    required this.totalSpace,
  });

  static Future<DiskSpaceInfo> fromTempDir() async {
    final tempDir = await getAppTemporaryDirectory();
    final freeSpace = await DiskSpace.getFreeDiskSpaceForPath(tempDir.path);
    final totalSpace = await DiskSpace.getTotalDiskSpace;

    // Convert from mebibytes (2^20 bytes) to bytes
    const mebibytesToBytes = 1024 * 1024;

    return DiskSpaceInfo(
      freeSpace: ((freeSpace ?? 0) * mebibytesToBytes).toInt(),
      totalSpace: ((totalSpace ?? 0) * mebibytesToBytes).toInt(),
    );
  }

  final int freeSpace;
  final int totalSpace;

  int get usedSpace => totalSpace - freeSpace;
  double get usagePercentage => totalSpace > 0 ? usedSpace / totalSpace : 0.0;

  static DiskSpaceInfo zero = DiskSpaceInfo(
    freeSpace: 0,
    totalSpace: 0,
  );
}
