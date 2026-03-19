// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:extended_image/extended_image.dart';

// Project imports:
import '../filesystem.dart';
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

  static var zero = DirectorySizeInfo(
    directoryCount: 0,
    fileCount: 0,
    size: 0,
  );
}

Future<DirectorySizeInfo> getDirectorySize(
  AppFileSystem fs,
  String dirPath, {
  List<String> excludedDirNames = const [],
}) async {
  var size = 0;
  var fileCount = 0;
  var directoryCount = 0;

  try {
    await for (final entry in fs.listDirectoryStream(
      dirPath,
      followLinks: false,
    )) {
      if (entry.isDirectory) {
        final dirName = basename(entry.path);
        if (excludedDirNames.contains(dirName)) {
          continue;
        }

        final subDirSizeInfo = await getDirectorySize(fs, entry.path);
        size += subDirSizeInfo.size;
        fileCount += subDirSizeInfo.fileCount;
        directoryCount += subDirSizeInfo.directoryCount + 1;
      } else if (entry.isFile) {
        size += await fs.fileSize(entry.path);
        fileCount++;
      }
    }
  } catch (e) {
    // ignore
  }

  return DirectorySizeInfo(
    size: size,
    fileCount: fileCount,
    directoryCount: directoryCount,
  );
}

Future<DirectorySizeInfo> getCacheSize(AppFileSystem fs) async {
  final cacheDirPath = await fs.getTemporaryPath();

  if (cacheDirPath == null) return DirectorySizeInfo.zero;

  return getDirectorySize(
    fs,
    cacheDirPath,
    excludedDirNames: [
      cacheImageFolderName,
      VideoCacheManager.defaultSubPath,
    ],
  );
}

Future<DirectorySizeInfo> getImageCacheSize(AppFileSystem fs) async {
  final cacheDirPath = await fs.getTemporaryPath();

  if (cacheDirPath == null) return DirectorySizeInfo.zero;

  final path = join(cacheDirPath, cacheImageFolderName);
  return getDirectorySize(fs, path);
}

Future<DirectorySizeInfo> getVideoCacheSize(AppFileSystem fs) async {
  final cacheDirPath = await fs.getTemporaryPath();

  if (cacheDirPath == null) return DirectorySizeInfo.zero;

  final path = join(cacheDirPath, VideoCacheManager.defaultSubPath);
  return getDirectorySize(fs, path);
}

Future<void> clearCache(AppFileSystem fs) async {
  final cacheDirPath = await fs.getTemporaryPath();

  if (cacheDirPath == null) return;

  if (fs.directoryExistsSync(cacheDirPath)) {
    if (isWindows()) {
      try {
        await for (final entry in fs.listDirectoryStream(cacheDirPath)) {
          try {
            if (entry.isDirectory) {
              await fs.deleteDirectory(entry.path, recursive: true);
            } else {
              await fs.deleteFile(entry.path);
            }
          } catch (e) {
            // Silently ignore deletion errors for individual files/folders
          }
        }
      } catch (e) {
        // Silently ignore if we can't list directory contents
      }
    } else {
      fs.deleteDirectorySync(cacheDirPath, recursive: true);
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

  static Future<DiskSpaceInfo> fromTempDir(AppFileSystem fs) async {
    final tempDirPath = await fs.getTemporaryPath();

    if (tempDirPath == null) return DiskSpaceInfo.zero;

    final freeSpace = await DiskSpace.getFreeDiskSpaceForPath(tempDirPath);
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

  static var zero = DiskSpaceInfo(
    freeSpace: 0,
    totalSpace: 0,
  );
}
