// Dart imports:
import 'dart:io';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

// Project imports:
import '../../core/foundation/loggers.dart';
import '../iap/iap.dart';
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
      'Revenuecat API key is empty, make sure to set it in your environment',
    );
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

  final iap = RevenuecatPurchase(logger);

  await iap.init();

  final subscriptionManager = RevenuecatSubscriptionManager(
    logger: logger,
    purchase: iap,
  );

  final activePackages =
      await getActiveSubscriptionPackages(subscriptionManager);

  return (iap, subscriptionManager, activePackages?.firstOrNull);
}
