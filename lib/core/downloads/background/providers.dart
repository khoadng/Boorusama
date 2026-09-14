// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/platform.dart';
import '../downloader/providers.dart';
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

final backgroundDownloaderProvider = Provider<BackgroundDownloader>((ref) {
  final service = ref.watch(downloadServiceProvider);
  if (service case final BackgroundDownloader downloader) return downloader;

  throw StateError(
    'backgroundDownloaderProvider requires a BackgroundDownloader service',
  );
});
