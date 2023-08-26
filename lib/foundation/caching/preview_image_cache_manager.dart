// ignore_for_file: implementation_imports

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system_io.dart';

// Project imports:
import 'package:boorusama/foundation/networking/dio_http_file_service.dart';

class PreviewImageCacheManager extends CacheManager {
  PreviewImageCacheManager({
    required Dio dio,
  }) : super(Config(
          _key,
          stalePeriod: const Duration(days: 1),
          maxNrOfCacheObjects: 1000,
          repo: JsonCacheInfoRepository(databaseName: _key),
          fileSystem: IOFileSystem(_key),
          fileService: DioHttpFileService(dio),
        ));

  static const _key = 'appPreviewImageCache';
}
