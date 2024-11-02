// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';
import '../iap/iap.dart' as i;
import 'constants.dart';
import 'converter.dart';

const _kServiceName = 'Revenuecat';

class RevenuecatPurchase implements i.InAppPurchase {
  RevenuecatPurchase(this.logger);

  final Logger logger;

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
      logger.logE(_kServiceName, 'Package not found: ${package.id}');

      return Future.value(false);
    }

    final customerInfo = await Purchases.purchasePackage(revenuecatPackage);

    final entitlement = customerInfo.entitlements.all[kPremiumKey];

    if (entitlement == null) {
      logger.logE(_kServiceName, 'Entitlement not found: $kPremiumKey');

      return Future.value(false);
    }

    return entitlement.isActive;
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
