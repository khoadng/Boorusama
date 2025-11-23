import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'cache_manager.dart';
import 'cache_utils.dart' as cache_utils;
import 'memory_cache.dart';

class DefaultImageCacheManager implements ImageCacheManager {
  DefaultImageCacheManager({
    this.cacheDirName = 'cacheimage',
    this.enableLogging = false,
    MemoryCache? memoryCache,
  }) : _memoryCache = memoryCache;

  final String cacheDirName;
  final bool enableLogging;
  final MemoryCache? _memoryCache;

  Directory? _cacheDir;
  Future<Directory>? _cacheDirFuture;
  final _keyCache = <String, String>{};

  /// Get the cache directory, creating it if needed
  FutureOr<Directory> getCacheDirectory() {
    // Return cached directory immediately if available (synchronous)
    if (_cacheDir != null) {
      return _cacheDir!;
    }

    // If initialization is already in progress, await that same future
    if (_cacheDirFuture != null) {
      return _cacheDirFuture!;
    }

    // Start initialization and cache the future
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
          _log('Cache expired for file: ${cacheFile.path}');
          try {
            unawaited(cacheFile.delete());
          } catch (e) {
            _log('Error deleting expired cache file: $e');
          }
          return null;
        }
      }

      return cacheFile;
    } catch (e) {
      _log('Error getting cached file: $e');
      return null;
    }
  }

  @override
  FutureOr<Uint8List?> getCachedFileBytes(String key, {Duration? maxAge}) {
    final memoryData = _memoryCache?.get(key);
    if (memoryData != null) {
      return memoryData;
    }

    final fileResult = _getCachedFile(key, maxAge: maxAge);

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => _readFileBytes(file, key));
    }

    final file = fileResult;
    return _readFileBytes(file, key);
  }

  FutureOr<Uint8List?> _readFileBytes(File? file, String key) {
    if (file == null) return null;

    try {
      return file.readAsBytes().then((data) {
        _cacheInMemoryIfEligible(key, data);
        return data;
      });
    } catch (e) {
      _log('Error reading cache: $e');
      return null;
    }
  }

  void _cacheInMemoryIfEligible(String key, Uint8List bytes) {
    _memoryCache?.put(key, bytes);
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));
      await cacheFile.writeAsBytes(bytes);

      // Save to memory cache if eligible
      _cacheInMemoryIfEligible(key, bytes);
    } catch (e) {
      _log('Failed to write cache: $e');
    }
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    if (_memoryCache?.contains(key) == true) {
      return true;
    }

    final fileResult = _getCachedFile(key, maxAge: maxAge);

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => file != null);
    }

    return fileResult != null;
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      _memoryCache?.remove(key);

      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));

      if (cacheFile.existsSync()) {
        await cacheFile.delete();
      }
    } catch (e) {
      _log('Error clearing cache: $e');
    }
  }

  @override
  String generateCacheKey(String url, {String? customKey}) {
    return cache_utils.generateCacheKey(
      url,
      customKey: customKey,
      keyToMd5: _keyToMd5,
    );
  }

  String _keyToMd5(String key) {
    if (_keyCache.containsKey(key)) {
      return _keyCache[key]!;
    }
    final md5Key = cache_utils.keyToMd5(key);
    _keyCache[key] = md5Key;
    return md5Key;
  }

  /// Invalidates the cached directory reference
  /// This should be called when the cache directory might be deleted externally
  @override
  void invalidateCacheDirectory() {
    _cacheDir = null;
    _cacheDirFuture = null;
  }

  @override
  Future<void> dispose() async {
    _memoryCache?.clear();
    _cacheDir = null;
    _cacheDirFuture = null;
    _keyCache.clear();
  }

  void _log(String message) {
    if (enableLogging) {
      print('[CacheManager] $message');
    }
  }
}
