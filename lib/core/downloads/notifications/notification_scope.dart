// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/router.dart';
import '../bulks/bulk_download_notifier.dart';
import '../bulks/bulk_download_task.dart';
import '../bulks/notifications/providers.dart';
import '../manager/download_task.dart';
import '../manager/download_tasks_notifier.dart';

class BulkDownloadNotificationScope extends ConsumerWidget {
  const BulkDownloadNotificationScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      downloadTasksProvider,
      (prev, cur) {
        final notifQueue = ref.read(bulkDownloadNotificationQueueProvider);

        if (notifQueue.isEmpty) return;

        for (final group in cur.tasks.keys) {
          if (!notifQueue.containsKey(group)) {
            continue;
          }

          final curComleted = cur.allCompleted(group);

          if (curComleted) {
            final task = ref.read(bulkdownloadProvider).firstWhereOrNull(
                  (e) => e.id == group,
                );

            if (task == null) return;

            ref.read(bulkDownloadNotificationProvider).showNotification(
                  task.displayName,
                  'Downloaded ${task.totalItems} files',
                );

            notifQueue.remove(group);

            ref.read(bulkDownloadNotificationQueueProvider.notifier).state = {
              ...notifQueue
            };
          }
        }
      },
    );

    ref.listen(
      bulkDownloadErrorNotificationQueueProvider,
      (prev, cur) {
        if (cur == null) return;

        ref.read(bulkDownloadErrorNotificationQueueProvider.notifier).state =
            null;

        showErrorToast(context, cur);
      },
    );

    ref.listen(
      bulkDownloadOnTapStreamProvider,
      (prev, cur) {
        if (prev == null) return;

        context.pushNamed(kBulkdownload);
      },
    );

    return child;
  }
}
