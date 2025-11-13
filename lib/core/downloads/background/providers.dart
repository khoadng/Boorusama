// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/loggers.dart';
import '../../videos/cache/providers.dart';
import 'downloader.dart';
import 'notification.dart';

final downloadNotificationsProvider = Provider<DownloadNotifications>(
  (ref) => DownloadNotifications.uninitialized(),
);

final backgroundDownloaderProvider = Provider<BackgroundDownloader>(
  (ref) {
    return BackgroundDownloader(
      videoCacheManager: ref.watch(videoCacheManagerProvider),
      downloadNotifications: ref.watch(downloadNotificationsProvider),
      logger: ref.watch(loggerProvider),
      androidSdkInt: ref.watch(
        deviceInfoProvider.select(
          (value) => value.androidDeviceInfo?.version.sdkInt,
        ),
      ),
    );
  },
);
