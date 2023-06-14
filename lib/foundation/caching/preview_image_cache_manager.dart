// ignore_for_file: implementation_imports

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system_io.dart';

class PreviewImageCacheManager extends CacheManager {
  PreviewImageCacheManager()
      : super(Config(
          _key,
          stalePeriod: const Duration(days: 1),
          maxNrOfCacheObjects: 1000,
          repo: JsonCacheInfoRepository(databaseName: _key),
          fileSystem: IOFileSystem(_key),
          fileService: HttpFileService(),
        ));

  static const _key = 'appPreviewImageCache';
}
