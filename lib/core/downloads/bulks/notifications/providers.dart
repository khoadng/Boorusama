// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'bulk_download_notification.dart';

final bulkDownloadNotificationProvider = Provider<BulkDownloadNotifications>(
  (ref) => throw UnimplementedError(),
);

final bulkDownloadNotificationQueueProvider =
    StateProvider<Map<String, bool>>((ref) => {});

final bulkDownloadErrorNotificationQueueProvider =
    StateProvider<String?>((ref) => null);

final bulkDownloadOnTapStreamProvider = StreamProvider<String>(
  (ref) {
    return ref.watch(bulkDownloadNotificationProvider).tapStream;
  },
);
