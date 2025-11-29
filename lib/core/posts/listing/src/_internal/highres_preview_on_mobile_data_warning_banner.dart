// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/networking.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/widgets.dart';

const _kHideHighresOnMobileDataWarningKey =
    'hide_highres_on_mobile_data_warning';

class HighresPreviewOnMobileDataWarningBanner extends ConsumerWidget {
  const HighresPreviewOnMobileDataWarningBanner({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageQuality = ref.watch(imageListingQualityProvider);
    final networkState = ref.watch(networkStateProvider);

    return switch (networkState) {
      final NetworkConnectedState s => PersistentDismissableInfoContainer(
        storageKey: _kHideHighresOnMobileDataWarningKey,
        shouldShow: () => s.result.isMobile && imageQuality.isHighres,
        mainColor: Theme.of(context).colorScheme.error,
        content: context.t.infinite_scroll.reminder.highres,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
