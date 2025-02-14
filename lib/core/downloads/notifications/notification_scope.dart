// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/toast.dart';
import '../../premiums/src/routes/routes.dart';
import '../../router.dart';
import '../bulks/notifications/providers.dart';
import '../bulks/providers/bulk_download_notifier.dart';
import '../bulks/types/bulk_download_error.dart';
import '../bulks/types/bulk_download_error_code.dart';

class BulkDownloadNotificationScope extends ConsumerWidget {
  const BulkDownloadNotificationScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    ref
      ..listen(
        bulkDownloadProvider.select((state) => state.error),
        (prev, cur) {
          if (prev == cur) return;

          if (cur != null && cur is BulkDownloadError) {
            final isPremiumError = cur.code.isPremiumError;

            showSimpleSnackBar(
              context: context,
              content: Text(cur.message),
              action: isPremiumError
                  ? SnackBarAction(
                      label: 'Upgrade',
                      textColor: Theme.of(context).colorScheme.surface,
                      onPressed: () => goToPremiumPage(context),
                    )
                  : null,
            );
            notifier.clearError();
          }
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
