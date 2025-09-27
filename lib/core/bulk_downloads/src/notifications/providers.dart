// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'bulk_download_notification.dart';

final bulkDownloadNotificationProvider = Provider<BulkDownloadNotifications>(
  (ref) => BulkDownloadNotifications.uninitialized(),
);

final bulkDownloadOnTapStreamProvider = StreamProvider<String>(
  (ref) => ref.watch(bulkDownloadNotificationProvider).tapStream,
);
