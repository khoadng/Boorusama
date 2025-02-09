// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../router.dart';
import '../bulks/notifications/providers.dart';
import '../bulks/providers/bulk_download_notifier.dart';

class BulkDownloadNotificationScope extends ConsumerWidget {
  const BulkDownloadNotificationScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..listen(
        taskCompleteCheckerProvider,
        (prev, cur) {
          // Just here to keep the listener active
        },
      )
      ..listen(
        bulkDownloadOnTapStreamProvider,
        (prev, cur) {
          if (prev == null) return;

          context.pushNamed(kBulkdownload);
        },
      );

    return child;
  }
}
