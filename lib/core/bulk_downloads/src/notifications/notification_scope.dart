// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../premiums/premiums.dart';
import '../../../premiums/src/routes/routes.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../types/bulk_download_error.dart';
import '../types/bulk_download_error_code.dart';
import 'providers.dart';

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
              content: Text(switch (cur.code) {
                BulkDownloadErrorCode.nonPremiumSavedTaskLimit =>
                  context.t.bulk_downloads.errors.non_premium_template_limit(
                    brand: kPremiumBrandName,
                  ),
                BulkDownloadErrorCode.nonPremiumSessionLimit =>
                  context.t.bulk_downloads.errors.non_premium_session_limit(
                    brand: kPremiumBrandName,
                  ),
                BulkDownloadErrorCode.nonPremiumResume =>
                  context.t.bulk_downloads.errors.non_premium_resume(
                    brand: kPremiumBrandName,
                  ),
                BulkDownloadErrorCode.runningSessionDeletion =>
                  context.t.bulk_downloads.errors.running_session_deletion,
                BulkDownloadErrorCode.nonPremiumSuspend =>
                  context.t.bulk_downloads.errors.non_premium_suspend(
                    brand: kPremiumBrandName,
                  ),
                _ => cur.message,
              }),
              action: isPremiumError
                  ? SnackBarAction(
                      label: context.t.premium.upgrade,
                      textColor: Theme.of(context).colorScheme.surface,
                      onPressed: () => goToPremiumPage(ref),
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

          goToBulkDownloadManagerPage(ref, go: true);
        },
      );

    return child;
  }
}
