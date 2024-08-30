// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'iap.dart';

abstract class SubscriptionManager {
  Future<bool> hasActiveSubscription(String id);
}

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, Package?>(
        () => throw UnimplementedError());

class SubscriptionNotifier extends Notifier<Package?> {
  final Package? initialPackage;
  final InAppPurchase iap;
  final SubscriptionManager manager;

  SubscriptionNotifier({
    required this.initialPackage,
    required this.iap,
    required this.manager,
  });

  @override
  Package? build() {
    return initialPackage;
  }

  Future<void> purchasePackage(Package package) async {
    final success = await iap.purchasePackage(package);
    if (success) {
      print('Purchased ${package.product.title}');
      state = package;
    }
  }
}
