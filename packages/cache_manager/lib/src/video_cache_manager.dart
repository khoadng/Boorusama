import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:background_downloader/background_downloader.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'cache_manager.dart';

class VideoCacheManager implements ImageCacheManager {
  VideoCacheManager({
    required this.fileDownloader,
    required this.dio,
    this.cacheDirName = defaultSubPath,
    this.maxTotalCacheSize = 1 * 1024 * 1024 * 1024, // 1GB
    this.maxItemSize = 100 * 1024 * 1024, // 100MB
    this.evictionThreshold = 0.8,
    this.enableLogging = false,
  });

  final String cacheDirName;
  final int maxTotalCacheSize;
  final int maxItemSize;
  final double evictionThreshold;
  final bool enableLogging;
  final FileDownloader fileDownloader;
  final Dio dio;

  Directory? _cacheDir;
  Future<Directory>? _cacheDirFuture;

  static const String defaultSubPath = 'cachevideo';
  static const String videoCacheGroup = 'video_cache';

  FutureOr<Directory> getCacheDirectory() {
    if (_cacheDir != null) {
      return _cacheDir!;
    }

    if (_cacheDirFuture != null) {
      return _cacheDirFuture!;
    }
    _cacheDirFuture = _initializeCacheDirectory();

    return _cacheDirFuture!
        .then((dir) {
          _cacheDir = dir;
          return dir;
        })
        .catchError((e) {
          _cacheDirFuture = null;
          throw e;
        });
  }

  Future<Directory> _initializeCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final dirPath = join(tempDir.path, cacheDirName);
    final dir = Directory(dirPath);

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  @override
  String generateCacheKey(String url, {String? customKey}) {
    if (customKey != null) {
      return customKey;
    }

    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    final fileResult = _getCachedFile(key, maxAge: maxAge);

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => file != null);
    }

    return fileResult != null;
  }

  Future<bool> isVideoCached(String url, {Duration? maxAge}) async {
    final cacheKey = generateCacheKey(url);
    return await hasValidCache(cacheKey, maxAge: maxAge);
  }

  FutureOr<File?> _getCachedFile(String key, {Duration? maxAge}) {
    final dirResult = getCacheDirectory();

    if (dirResult is Future<Directory>) {
      return dirResult.then((cacheDir) => _getValidFile(cacheDir, key, maxAge));
    }

    final cacheDir = dirResult;
    return _getValidFile(cacheDir, key, maxAge);
  }

  @override
  FutureOr<String?> getCachedFilePath(String key, {Duration? maxAge}) async {
    final fileResult = await _getCachedFile(key, maxAge: maxAge);

    return fileResult?.path;
  }

  File? _getValidFile(Directory cacheDir, String key, Duration? maxAge) {
    try {
      final cacheFile = File(join(cacheDir.path, key));
      final stats = cacheFile.statSync();

      if (stats.type == FileSystemEntityType.notFound) {
        return null;
      }

      if (maxAge != null) {
        final now = DateTime.now();
        final isExpired = now.subtract(maxAge).isAfter(stats.modified);
        if (isExpired) {
          _log('Cache expired for video file: ${cacheFile.path}');
          try {
            cacheFile.deleteSync();
          } catch (e) {
            _log('Error deleting expired video cache file: $e');
          }
          return null;
        }
      }

      return cacheFile;
    } catch (e) {
      _log('Error getting cached video file: $e');
      return null;
    }
  }

  @override
  FutureOr<Uint8List?> getCachedFileBytes(String key, {Duration? maxAge}) {
    final fileResult = _getCachedFile(key, maxAge: maxAge);

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => _readFileBytes(file, key));
    }

    final file = fileResult;
    return _readFileBytes(file, key);
  }

  Future<String?> getCachedVideoPath(String url, {Duration? maxAge}) async {
    final cacheKey = generateCacheKey(url);
    final file = await _getCachedFile(cacheKey, maxAge: maxAge);

    if (file != null && file.existsSync()) {
      await _touchFile(file);
      return file.path;
    }

    return null;
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    // Noop - not used for video caching, cacheVideo handles everything
  }

  Future<String?> cacheVideo(
    String url, {
    Map<String, String>? headers,
    int? fileSize,
  }) async {
    if (await isVideoCached(url)) {
      return null;
    }

    try {
      int? estimatedSize = fileSize;

      // Only make HEAD request if file size not provided
      if (estimatedSize == null) {
        final headResponse = await dio.head(
          url,
          options: Options(headers: headers),
        );

        final contentLength = headResponse.headers.value('content-length');
        if (contentLength != null) {
          estimatedSize = int.tryParse(contentLength);
        }
      }

      // Check file size limit
      if (estimatedSize != null &&
          maxItemSize != -1 &&
          estimatedSize > maxItemSize) {
        throw VideoCacheException(
          'Video too large: $estimatedSize bytes exceeds max item size of $maxItemSize bytes',
        );
      }

      // Ensure space before downloading
      if (maxTotalCacheSize != -1 && estimatedSize != null) {
        await _ensureSpaceAvailable(estimatedSize);
      }

      final cacheDir = await getCacheDirectory();
      final cacheKey = generateCacheKey(url);

      final task = DownloadTask(
        url: url,
        filename: cacheKey,
        baseDirectory: BaseDirectory.root,
        directory: cacheDir.path,
        allowPause: false,
        retries: 1,
        updates: Updates.none,
        headers: headers,
        group: videoCacheGroup,
      );

      final existingTask = await fileDownloader.taskForId(task.taskId);
      if (existingTask != null) {
        return existingTask.taskId;
      }

      await fileDownloader.enqueue(task);
      return task.taskId;
    } catch (e) {
      _log('Failed to preload video: $e');
      rethrow;
    }
  }

  Future<bool> cancelPreload(String taskId) async {
    try {
      return await fileDownloader.cancelTaskWithId(taskId);
    } catch (e) {
      _log('Failed to cancel preload: $e');
      return false;
    }
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));

      if (cacheFile.existsSync()) {
        await cacheFile.delete();
      }
    } catch (e) {
      _log('Error clearing video cache: $e');
    }
  }

  Future<void> clearVideo(String url) async {
    final cacheKey = generateCacheKey(url);
    await clearCache(cacheKey);
  }

  Future<void> clearAllVideos() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
        invalidateCacheDirectory();
      }
    } catch (e) {
      _log('Error clearing all video cache: $e');
    }
  }

  @override
  void invalidateCacheDirectory() {
    _cacheDir = null;
    _cacheDirFuture = null;
  }

  @override
  Future<void> dispose() async {
    _cacheDir = null;
    _cacheDirFuture = null;
  }

  FutureOr<Uint8List?> _readFileBytes(File? file, String key) {
    if (file == null) return null;

    try {
      return file.readAsBytes();
    } catch (e) {
      _log('Error reading video cache: $e');
      return null;
    }
  }

  Future<void> _touchFile(File file) async {
    try {
      final now = DateTime.now();
      await file.setLastModified(now);
    } catch (e) {
      _log('Error touching video cache file: $e');
    }
  }

  Future<void> _ensureSpaceAvailable(int spaceNeeded) async {
    if (maxTotalCacheSize == -1) {
      return;
    }

    final cacheDir = await getCacheDirectory();
    final targetThreshold = (maxTotalCacheSize * evictionThreshold).round();

    final files = cacheDir.listSync().whereType<File>().toList();
    var currentSize = 0;

    final fileStats = <_FileWithStats>[];
    for (final file in files) {
      try {
        final stat = file.statSync();
        currentSize += stat.size;
        fileStats.add(_FileWithStats(file, stat));
      } catch (e) {
        _log('Error accessing file during eviction: $e');
      }
    }

    fileStats.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));

    final maxAllowedSize = targetThreshold - spaceNeeded;

    for (final fileWithStat in fileStats) {
      if (currentSize <= maxAllowedSize) break;

      try {
        await fileWithStat.file.delete();
        currentSize -= fileWithStat.stat.size;
        _log(
          'Evicted file: ${fileWithStat.file.path} (${fileWithStat.stat.size} bytes)',
        );
      } catch (e) {
        _log('Error deleting file during eviction: $e');
      }
    }
  }

  void _log(String message) {
    if (enableLogging) {
      print('[VideoCacheManager] $message');
    }
  }
}

class _FileWithStats {
  const _FileWithStats(this.file, this.stat);
  final File file;
  final FileStat stat;
}

class VideoCacheException implements Exception {
  const VideoCacheException(this.message);
  final String message;

  @override
  String toString() => 'VideoCacheException: $message';
}
