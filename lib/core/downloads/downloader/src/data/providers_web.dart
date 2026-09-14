// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../providers/download_notifier.dart';
import '../types/download.dart';
import '../types/download_service_factory.dart';

final downloadServiceFactoryProvider = Provider<DownloadServiceFactory>(
  (_) => throw UnimplementedError(
    'downloadServiceFactoryProvider must be overridden',
  ),
  name: 'downloadServiceFactoryProvider',
);

DownloadServiceFactory createProductionDownloadServiceFactory() =>
    const WebDownloadServiceFactory();

final downloadServiceProvider = Provider<DownloadService>(
  (ref) {
    final factory = ref.watch(downloadServiceFactoryProvider);
    final service = factory.create(
      const DownloadServiceDependencies(
        fileSystem: null,
        logger: null,
        sidecarStore: null,
        videoCacheManager: null,
        androidSdkInt: null,
      ),
    );
    ref.onDispose(() => factory.dispose(service));
    return service;
  },
);

final class WebDownloadServiceFactory implements DownloadServiceFactory {
  const WebDownloadServiceFactory();

  @override
  DownloadService create(DownloadServiceDependencies dependencies) =>
      const WebDownloadService();

  @override
  Future<void> dispose(DownloadService service) async {}
}

final downloadMultipleFileCheckProvider =
    Provider.family<MultipleFileDownloadCheck, BooruConfigAuth>(
      (ref, config) =>
          () => config.booruType.canDownloadMultipleFiles,
    );

class WebDownloadService implements DownloadService {
  const WebDownloadService();

  @override
  Future<bool> cancelAll(String group) {
    return Future.value(false);
  }

  @override
  Future<DownloadResult> download(DownloadOptions options) {
    return Future.value(
      DownloadFailure(
        GenericDownloadError(
          savedPath: none(),
          fileName: options.filename,
          message: 'Downloading is not supported on web',
        ),
      ),
    );
  }

  @override
  Future<void> pauseAll(String group) {
    return Future.value();
  }

  @override
  Future<void> resumeAll(String group) {
    return Future.value();
  }
}
