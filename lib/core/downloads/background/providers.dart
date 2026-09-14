// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/filesystem.dart';
import '../../../foundation/info/device_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/platform.dart';
import '../../videos/cache/providers.dart';
import '../sidecar/providers.dart';
import 'downloader.dart';
import 'notification.dart';

final downloadNotificationsProvider = Provider<DownloadNotifications>((ref) {
  final notifications = DownloadNotifications.uninitialized(
    platform: ref.watch(appPlatformProvider),
  );
  ref.onDispose(notifications.dispose);
  return notifications;
});

final downloadNotificationTapProvider = StreamProvider<String>(
  (ref) => ref.watch(downloadNotificationsProvider).tapStream,
);

final backgroundDownloaderProvider = Provider<BackgroundDownloader>(
  (ref) {
    return BackgroundDownloader(
      videoCacheManager: ref.watch(videoCacheManagerProvider),
      logger: ref.watch(loggerProvider),
      fs: ref.watch(appFileSystemProvider),
      sidecarStore: ref.watch(sidecarStoreProvider.future),
      androidSdkInt: ref.watch(
        deviceInfoProvider.select(
          (value) => value.androidDeviceInfo?.version.sdkInt,
        ),
      ),
    );
  },
);
