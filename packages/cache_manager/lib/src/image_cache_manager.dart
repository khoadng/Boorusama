import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'cache_directory.dart';
import 'cache_key_generator.dart';
import 'cache_logger.dart';
import 'cache_manager.dart';
import 'file_manager.dart';
import 'memory_cache.dart';

class ImageCacheManager implements CacheManager {
  ImageCacheManager({
    required this.fileManager,
    required this.cacheDir,
    required this.keyGenerator,
    required this.logger,
    MemoryCache? memoryCache,
  }) : _memoryCache = memoryCache;

  final FileManager fileManager;
  final CacheDirectory cacheDir;
  final CacheKeyGenerator keyGenerator;
  final CacheLogger logger;
  final MemoryCache? _memoryCache;

  static const String defaultSubPath = 'cacheimage';

  factory ImageCacheManager.defaults({
    int memoryCacheMaxEntries = 1000,
    bool enableLogging = false,
  }) => ImageCacheManager(
    fileManager: FileManager(),
    cacheDir: CacheDirectory(
      getBaseDirectory: getTemporaryDirectory,
      subPath: defaultSubPath,
    ),
    keyGenerator: DefaultCacheKeyGenerator(),
    logger: CacheLogger(
      tag: 'CacheManager',
      enableLogging: enableLogging,
    ),
    memoryCache: LRUMemoryCache(maxEntries: memoryCacheMaxEntries),
  );

  @override
  FutureOr<File?> getCachedFile(String key) {
    final dirResult = this.cacheDir.get();

    if (dirResult is Future<Directory>) {
      return dirResult.then((cacheDir) {
        final filePath = join(cacheDir.path, key);
        return fileManager.getFileIfExists(filePath);
      });
    }

    final cacheDir = dirResult;
    final filePath = join(cacheDir.path, key);
    return fileManager.getFileIfExists(filePath);
  }

  @override
  FutureOr<Uint8List?> getCachedFileBytes(String key) {
    final memoryData = _memoryCache?.get(key);
    if (memoryData != null) {
      return memoryData;
    }

    final fileResult = getCachedFile(key);

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => _readFileBytes(file, key));
    }

    final file = fileResult;
    return _readFileBytes(file, key);
  }

  FutureOr<Uint8List?> _readFileBytes(File? file, String key) {
    if (file == null) return null;

    try {
      return fileManager.readFileBytes(file.path).then((data) {
        if (data != null) {
          _cacheInMemoryIfEligible(key, data);
        }
        return data;
      });
    } catch (e) {
      logger.log('Error reading cache: $e');
      return null;
    }
  }

  void _cacheInMemoryIfEligible(String key, Uint8List bytes) {
    _memoryCache?.put(key, bytes);
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    try {
      final cacheDir = await this.cacheDir.get();
      final filePath = join(cacheDir.path, key);
      await fileManager.writeFileBytes(filePath, bytes);

      // Save to memory cache if eligible
      _cacheInMemoryIfEligible(key, bytes);
    } catch (e) {
      logger.log('Failed to write cache: $e');
    }
  }

  FutureOr<bool> _deleteExpired(String filePath, Duration? maxAge) {
    if (maxAge == null) {
      return true; // No expiration check needed
    }

    final fileStats = fileManager.getFileStats(filePath);
    if (fileStats == null) return false;

    final now = DateTime.now();
    final isExpired = now.subtract(maxAge).isAfter(fileStats.modified);
    if (!isExpired) return true;

    return fileManager.deleteFile(filePath).then((_) => false).catchError((e) {
      logger.log('Error deleting expired cache file: $e');
      return false;
    });
  }

  bool _fileExists(Directory cacheDir, String key) {
    final filePath = join(cacheDir.path, key);
    return fileManager.fileExists(filePath);
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    if (_memoryCache?.contains(key) == true) {
      return true;
    }

    final dirResult = this.cacheDir.get();

    if (dirResult is Future<Directory>) {
      return dirResult.then((cacheDir) {
        if (!_fileExists(cacheDir, key)) return false;

        final filePath = join(cacheDir.path, key);
        return _deleteExpired(filePath, maxAge);
      });
    }

    final cacheDir = dirResult;
    if (!_fileExists(cacheDir, key)) return false;

    final filePath = join(cacheDir.path, key);
    return _deleteExpired(filePath, maxAge);
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      _memoryCache?.remove(key);

      final cacheDir = await this.cacheDir.get();
      final filePath = join(cacheDir.path, key);
      await fileManager.deleteFile(filePath);
    } catch (e) {
      logger.log('Error clearing cache: $e');
    }
  }

  @override
  String generateCacheKey(String url, {String? customKey}) =>
      keyGenerator.generateKey(url, customKey: customKey);

  /// Invalidates the cached directory reference
  /// This should be called when the cache directory might be deleted externally
  @override
  void invalidateCacheDirectory() => cacheDir.invalidate();

  @override
  Future<void> dispose() async {
    _memoryCache?.clear();
    cacheDir.dispose();
  }
}
