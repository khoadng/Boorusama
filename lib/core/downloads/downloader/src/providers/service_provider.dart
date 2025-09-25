// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../videos/providers.dart';
import '../../../notifications/notification.dart';
import '../types/download.dart';
import 'background_downloader.dart';

final downloadNotificationsProvider = FutureProvider<DownloadNotifications>(
  (ref) => DownloadNotifications.create(),
);

final downloadServiceProvider = Provider<DownloadService>(
  (ref) => BackgroundDownloader(
    videoCacheManager: ref.watch(videoCacheManagerProvider),
    downloadNotificationsFuture: ref.watch(
      downloadNotificationsProvider.future,
    ),
  ),
);
