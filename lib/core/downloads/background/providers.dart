// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../videos/cache/providers.dart';
import 'downloader.dart';
import 'notification.dart';

final downloadNotificationsProvider = Provider<DownloadNotifications>(
  (ref) => DownloadNotifications.uninitialized(),
);

final backgroundDownloaderProvider = Provider<BackgroundDownloader>(
  (ref) => BackgroundDownloader(
    videoCacheManager: ref.watch(videoCacheManagerProvider),
    downloadNotifications: ref.watch(downloadNotificationsProvider),
  ),
);
