// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../iap/iap.dart' as i;
import 'constants.dart';
import 'converter.dart';

class RevenuecatPurchase implements i.InAppPurchase {
  final Map<String, Package> _packages = {};

  @override
  Future<List<i.Package>> getAvailablePackages() async {
    final offerings = await Purchases.getOfferings();

    if (offerings.current == null ||
        offerings.current!.availablePackages.isEmpty) {
      return [];
    }

    final packages = offerings.current!.availablePackages;

    // cache it so we can use it later
    _packages.clear();

    for (final package in packages) {
      _packages[package.identifier] = package;
    }

    return packages
        .map((package) => mapRevenuecatPackageToPackage(package))
        .toList();
  }

  @override
  Future<bool> purchasePackage(i.Package package) async {
    final revenuecatPackage = _packages[package.id];

    if (revenuecatPackage == null) {
      return Future.value(false);
    }

    final customerInfo = await Purchases.purchasePackage(revenuecatPackage);

    return customerInfo.entitlements.all[kPremiumKey]?.isActive ?? false;
  }

  @override
  Future<bool?> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();

    return customerInfo.entitlements.all[kPremiumKey]?.isActive;
  }
}

class RevenuecatSubscriptionManager implements i.SubscriptionManager {
  const RevenuecatSubscriptionManager({
    required this.managementURL,
  });

  @override
  Future<bool> hasActiveSubscription(String id) async {
    final customerInfo = await Purchases.getCustomerInfo();

    return customerInfo.entitlements.all[id]?.isActive ?? false;
  }

  @override
  final String? managementURL;
}
