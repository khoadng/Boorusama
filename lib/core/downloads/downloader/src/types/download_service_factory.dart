// Package imports:
import 'package:cache_manager/cache_manager.dart';

// Project imports:
import '../../../../../foundation/filesystem.dart';
import '../../../../../foundation/loggers.dart';
import '../../../sidecar/src/data/sidecar_store.dart';
import 'download.dart';

final class DownloadServiceDependencies {
  const DownloadServiceDependencies({
    required this.fileSystem,
    required this.logger,
    required this.sidecarStore,
    required this.videoCacheManager,
    required this.androidSdkInt,
  });

  final AppFileSystem? fileSystem;
  final Logger? logger;
  final Future<SidecarStore>? sidecarStore;
  final VideoCacheManager? videoCacheManager;
  final int? androidSdkInt;
}

abstract interface class DownloadServiceFactory {
  DownloadService create(DownloadServiceDependencies dependencies);

  Future<void> dispose(DownloadService service);
}
