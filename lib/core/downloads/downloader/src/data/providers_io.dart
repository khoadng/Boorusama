// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/filesystem.dart';
import '../../../../../foundation/info/device_info.dart';
import '../../../../../foundation/loggers.dart';
import '../../../../configs/config/types.dart';
import '../../../../videos/cache/providers.dart';
import '../../../background/factory.dart';
import '../../../sidecar/providers.dart';
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
    const BackgroundDownloadServiceFactory();

final downloadServiceProvider = Provider<DownloadService>(
  (ref) {
    final factory = ref.watch(downloadServiceFactoryProvider);
    final service = factory.create(
      DownloadServiceDependencies(
        fileSystem: ref.watch(appFileSystemProvider),
        logger: ref.watch(loggerProvider),
        sidecarStore: ref.watch(sidecarStoreProvider.future),
        videoCacheManager: ref.watch(videoCacheManagerProvider),
        androidSdkInt: ref.watch(
          deviceInfoProvider.select(
            (value) => value.androidDeviceInfo?.version.sdkInt,
          ),
        ),
      ),
    );
    ref.onDispose(() => factory.dispose(service));
    return service;
  },
);

final downloadMultipleFileCheckProvider =
    Provider.family<MultipleFileDownloadCheck, BooruConfigAuth>(
      (ref, config) =>
          () => config.booruType.canDownloadMultipleFiles,
    );
