// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../videos/cache/providers.dart';
import '../../../notifications/notification.dart';
import '../types/download.dart';
import 'background_downloader.dart';

final downloadNotificationsProvider = Provider<DownloadNotifications>(
  (ref) => DownloadNotifications.uninitialized(),
);

final downloadServiceProvider = Provider<DownloadService>(
  (ref) => BackgroundDownloader(
    videoCacheManager: ref.watch(videoCacheManagerProvider),
    downloadNotifications: ref.watch(downloadNotificationsProvider),
  ),
);
