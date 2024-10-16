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

final packagePurchaseProvider =
    AsyncNotifierProvider.autoDispose<PackagePurchaseNotifier, bool?>(
        PackagePurchaseNotifier.new);

class PackagePurchaseNotifier extends AutoDisposeAsyncNotifier<bool?> {
  @override
  Future<bool?> build() {
    return Future.value(null);
  }

  Future<void> startPurchase(Package package) async {
    try {
      state = const AsyncLoading();

      final notifier = ref.read(subscriptionNotifierProvider.notifier);

      await notifier.purchasePackage(package);

      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

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
      state = package;
    }
  }

  Future<void> cancelSubscription() async {
    state = null;
  }

  Future<bool?> restoreSubscription() async {
    final res = await iap.restorePurchases();

    return res;
  }
}
