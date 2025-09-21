import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' show join;

class CacheDirectory {
  CacheDirectory({
    required this.getBaseDirectory,
    required this.subPath,
  });

  final Future<Directory> Function() getBaseDirectory;
  final String subPath;

  Directory? _cacheDir;
  Future<Directory>? _cacheDirFuture;

  FutureOr<Directory> get() {
    if (_cacheDir != null) {
      return _cacheDir!;
    }

    if (_cacheDirFuture != null) {
      return _cacheDirFuture!;
    }

    _cacheDirFuture = _initialize();

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

  Future<Directory> _initialize() async {
    final baseDir = await getBaseDirectory();
    final dirPath = join(baseDir.path, subPath);
    final dir = Directory(dirPath);

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  void invalidate() {
    _cacheDir = null;
    _cacheDirFuture = null;
  }

  void dispose() {
    _cacheDir = null;
    _cacheDirFuture = null;
  }
}
