// Dart imports:
import 'dart:io';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

// Project imports:
import 'package:boorusama/foundation/iap/iap.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'constants.dart';
import 'revenuecat.dart';

export 'iap_impl.dart';

Future<void> initRevenuecat() async {
  final hasKey = Platform.isAndroid
      ? kRevenuecatGoogleApiKey.isNotEmpty
      : kRevenuecatAppleApiKey.isNotEmpty;

  // check if key is available
  if (!hasKey) {
    throw Exception(
        'Revenuecat API key is empty, make sure to set it in your environment');
  }

  final configuration = Platform.isAndroid
      ? rc.PurchasesConfiguration(kRevenuecatGoogleApiKey)
      : rc.PurchasesConfiguration(kRevenuecatAppleApiKey);

  await rc.Purchases.configure(configuration);
}

Future<(InAppPurchase, SubscriptionManager, Package?)> initRevenuecatIap(
  Logger logger,
) async {
  await initRevenuecat();

  final customerInfo = await rc.Purchases.getCustomerInfo();

  final iap = RevenuecatPurchase(logger);
  final subscriptionManager = RevenuecatSubscriptionManager(
    managementURL: customerInfo.managementURL,
  );

  final activePackage =
      await getActiveSubscriptionPackage(subscriptionManager, iap);

  return (iap, subscriptionManager, activePackage);
}
