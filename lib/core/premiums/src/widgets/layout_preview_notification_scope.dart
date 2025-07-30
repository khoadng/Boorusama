// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../providers/preview_providers.dart';
import '../routes/routes.dart';

class LayoutPreviewNotificationScope extends ConsumerWidget {
  const LayoutPreviewNotificationScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      premiumLayoutPreviewProvider.select((state) => state.status),
      (previous, next) {
        if (previous == LayoutPreviewStatus.on &&
            next == LayoutPreviewStatus.off) {
          // Notify user that the preview has ended
          showSimpleSnackBar(
            context: context,
            duration: const Duration(seconds: 10),
            content: Text(
              'Your layout preview has ended. Upgrade to continue using premium layouts or start a new preview.'
                  .hc,
            ),
            action: SnackBarAction(
              label: 'Upgrade'.hc,
              textColor: Theme.of(context).colorScheme.surface,
              onPressed: () => goToPremiumPage(ref),
            ),
          );
        }
      },
    );

    return child;
  }
}
