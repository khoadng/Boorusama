// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'iap.dart';

class DummyInAppPurchase implements InAppPurchase {
  DummyInAppPurchase({
    required this.packages,
  });

  final List<Package> packages;
  final List<Package> purchasedPackages = [];

  @override
  Future<void> restorePurchases() async {
    return;
  }

  @override
  Future<List<Package>> getAvailablePackages() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // append best value data that is compared to monthly subscription
    final monthly = packages
        .firstWhereOrNull((element) => element.type == PackageType.monthly);

    final data = monthly != null
        ? packages.map((e) => e.withDealFrom(monthly)).toList()
        : packages;

    return data;
  }

  @override
  Future<bool> purchasePackage(Package package) async {
    if (purchasedPackages.contains(package)) {
      await Future.delayed(const Duration(seconds: 2));

      return Future.value(true);
    }

    purchasedPackages.add(package);

    await Future.delayed(const Duration(seconds: 2));

    return Future.value(true);
  }
}

class DummySubscriptionManager implements SubscriptionManager {
  final DummyInAppPurchase iap;

  DummySubscriptionManager({
    required this.iap,
  });

  @override
  Future<bool> hasActiveSubscription(String id) async {
    final package =
        iap.purchasedPackages.firstWhereOrNull((element) => element.id == id);

    if (package == null) return false;

    return package.id == id;
  }
}
