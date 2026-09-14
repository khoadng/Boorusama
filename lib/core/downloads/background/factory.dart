// Project imports:
import '../downloader/types.dart';
import 'downloader.dart';

final class BackgroundDownloadServiceFactory implements DownloadServiceFactory {
  const BackgroundDownloadServiceFactory();

  @override
  DownloadService create(DownloadServiceDependencies dependencies) =>
      BackgroundDownloader(
        videoCacheManager: dependencies.videoCacheManager,
        logger: dependencies.logger,
        fs: dependencies.fileSystem!,
        sidecarStore: dependencies.sidecarStore!,
        androidSdkInt: dependencies.androidSdkInt,
      );

  @override
  Future<void> dispose(DownloadService service) async {}
}
