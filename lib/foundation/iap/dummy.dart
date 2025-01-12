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
  Future<bool?> restorePurchases() async {
    await Future.delayed(const Duration(seconds: 1));

    return true;
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

  @override
  String? describePurchaseError(Object error) {
    return error.toString();
  }
}

class DummySubscriptionManager implements SubscriptionManager {
  DummySubscriptionManager({
    required this.iap,
  });

  final DummyInAppPurchase iap;

  @override
  Future<bool> hasActiveSubscription(String id) async {
    final package =
        iap.purchasedPackages.firstWhereOrNull((element) => element.id == id);

    if (package == null) return false;

    return package.id == id;
  }

  @override
  Future<String?> get managementURL => Future.value(null);

  @override
  Future<List<Package>> getActiveSubscriptions() {
    return Future.value(iap.purchasedPackages);
  }
}
