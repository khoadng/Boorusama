// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/networking.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../widgets/widgets.dart';

class HighresPreviewOnMobileDataWarningBanner extends ConsumerWidget {
  const HighresPreviewOnMobileDataWarningBanner({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageQuality = ref.watch(imageListingQualityProvider);

    return switch (ref.watch(networkStateProvider)) {
      final NetworkConnectedState s =>
        s.result.isMobile && imageQuality.isHighres
            ? DismissableInfoContainer(
                mainColor: Theme.of(context).colorScheme.error,
                content:
                    'Caution: The app is displaying high-resolution images using mobile data.',
              )
            : const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }
}
