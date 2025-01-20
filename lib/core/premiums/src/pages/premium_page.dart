// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/iap/iap.dart';
import 'premium_manage_page.dart';
import 'premium_offers_page.dart';

class PremiumPage extends ConsumerWidget {
  const PremiumPage({
    super.key,
    this.canGoBack = true,
  });

  final bool canGoBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(subscriptionNotifierProvider);

    return package != null
        ? PremiumManagePage(package: package)
        : PremiumOffersPage(
            canGoBack: canGoBack,
          );
  }
}
