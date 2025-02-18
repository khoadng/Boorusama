// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'bulk_download_notification.dart';

final bulkDownloadNotificationProvider =
    FutureProvider<BulkDownloadNotifications>(
  (ref) => BulkDownloadNotifications.create(),
);

final bulkDownloadOnTapStreamProvider = StreamProvider<String>(
  (ref) => ref.watch(bulkDownloadNotificationProvider).maybeWhen(
        data: (notifications) => notifications.tapStream,
        orElse: () => const Stream.empty(),
      ),
);
