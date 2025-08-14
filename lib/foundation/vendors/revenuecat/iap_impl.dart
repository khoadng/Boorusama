// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../iap/iap.dart' as i;
import '../../loggers.dart';
import '../../platform.dart';
import 'constants.dart';
import 'converter.dart';

const _kServiceName = 'Revenuecat';

class RevenuecatPurchase implements i.Purchaser {
  RevenuecatPurchase(this.logger);

  final Logger logger;

  final Map<String, Package> _packages = {};

  Future<void> init() async {
    logger.info(_kServiceName, 'Initializing...');

    final appUserId = await Purchases.appUserID;

    logger.info(_kServiceName, 'App user ID: $appUserId');

    await getAvailablePackages();
  }

  @override
  Future<List<i.Package>> getAvailablePackages() async {
    final offerings = await Purchases.getOfferings();

    if (offerings.current == null ||
        offerings.current!.availablePackages.isEmpty) {
      logger.warn(_kServiceName, 'No available packages found');

      return [];
    }

    final packages = offerings.current!.availablePackages;

    // cache it so we can use it later
    _packages.clear();

    for (final package in packages) {
      _packages[package.identifier] = package;
    }

    return getPackagesFromNames(
      packages.map((e) => e.identifier).toList(),
    );
  }

  List<i.Package> getPackagesFromNames(List<String> names) {
    final packages = <i.Package>[];

    for (final name in names) {
      final package = _packages[name];

      if (package != null) {
        packages.add(mapRevenuecatPackageToPackage(package));
      }
    }

    return packages;
  }

  List<i.Package> getPackagesFromProductSkus(List<String> skus) {
    final packages = <i.Package>[];

    for (final sku in skus) {
      // find the package that has the same product sku
      final package = _packages.entries
          .firstWhereOrNull(
            (element) => element.value.storeProduct.identifier == sku,
          )
          ?.value;

      if (package != null) {
        packages.add(mapRevenuecatPackageToPackage(package));
      }
    }

    return packages;
  }

  @override
  Future<bool> purchasePackage(i.Package package) async {
    final revenuecatPackage = _packages[package.id];

    if (revenuecatPackage == null) {
      logger.error(_kServiceName, 'Package not found: ${package.id}');

      return Future.value(false);
    }

    try {
      final purchaseResult = await Purchases.purchasePackage(revenuecatPackage);

      final entitlement =
          purchaseResult.customerInfo.entitlements.all[kPremiumKey];

      if (entitlement == null) {
        logger.error(_kServiceName, 'Entitlement not found: $kPremiumKey');

        return Future.value(false);
      }

      return entitlement.isActive;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      logger.error(
        _kServiceName,
        'Failed to purchase package: ${package.id}, $errorCode',
      );

      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        rethrow;
      }

      return false;
    }
  }

  @override
  Future<bool?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      final entitlement = customerInfo.entitlements.all[kPremiumKey];

      if (entitlement == null) {
        logger.error(_kServiceName, 'Entitlement not found: $kPremiumKey');

        return Future.value(false);
      }

      logger
        ..info(_kServiceName, 'Restored purchases successfully')
        ..info(
          _kServiceName,
          'Entitlement status: ${entitlement.isActive}, period: ${entitlement.periodType.name}',
        );

      return entitlement.isActive;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      logger.error(
        _kServiceName,
        'Failed to restore purchases, $errorCode',
      );

      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        rethrow;
      }

      return false;
    }
  }

  @override
  String? describePurchaseError(Object error) => switch (error) {
    final PlatformException pe => PurchasesErrorHelper.getErrorCode(pe).name,
    _ => null,
  };
}

const _kFallbackAndroidManagementURL =
    'https://play.google.com/store/account/subscriptions';

class RevenuecatSubscriptionManager implements i.SubscriptionManager {
  const RevenuecatSubscriptionManager({
    required this.logger,
    required this.purchase,
  });

  final Logger logger;
  final RevenuecatPurchase purchase;

  @override
  Future<bool> hasActiveSubscription(String id) async {
    final customerInfo = await Purchases.getCustomerInfo();

    return customerInfo.entitlements.all[id]?.isActive ?? false;
  }

  @override
  Future<List<i.Package>> getActiveSubscriptions() async {
    final customerInfo = await Purchases.getCustomerInfo();

    final skus = customerInfo.activeSubscriptions;

    return purchase.getPackagesFromProductSkus(skus);
  }

  @override
  Future<String?> get managementURL async {
    final customerInfo = await Purchases.getCustomerInfo();

    var managementURL = customerInfo.managementURL;

    if (managementURL == null) {
      logger.warn(_kServiceName, 'Management URL is null, using fallback');

      managementURL = isAndroid() ? _kFallbackAndroidManagementURL : null;
    }

    return managementURL;
  }
}
