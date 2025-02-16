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
    return ref.watch(subscriptionNotifierProvider).when(
          data: (package) => package != null
              ? PremiumManagePage(package: package)
              : PremiumOffersPage(
                  canGoBack: canGoBack,
                ),
          error: (error, _) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('Error: $error'),
            ),
          ),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}
