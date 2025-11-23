// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

// Project imports:
import '../../iap/iap.dart';
import '../../iap/iap_impl.dart';
import '../../loggers.dart';
import '../../platform.dart';
import 'constants.dart';
import 'iap_impl.dart';

export 'iap_impl.dart';

Future<bool> initRevenuecat({
  Logger? logger,
}) async {
  final hasKey = isAndroid()
      ? kRevenuecatGoogleApiKey.isNotEmpty
      : kRevenuecatAppleApiKey.isNotEmpty;

  // check if key is available
  if (!hasKey) {
    logger?.error(
      'Revenuecat',
      'Revenuecat API key is empty, make sure to set it in your environment',
    );
    return false;
  }

  final configuration = isAndroid()
      ? rc.PurchasesConfiguration(kRevenuecatGoogleApiKey)
      : rc.PurchasesConfiguration(kRevenuecatAppleApiKey);

  await rc.Purchases.configure(configuration);

  return true;
}

Future<IAP?> initRevenuecatIap(
  Logger logger,
) async {
  final success = await initRevenuecat(logger: logger);

  if (!success) {
    return null;
  }

  final iap = RevenuecatPurchase(logger);

  await iap.init();

  final subscriptionManager = RevenuecatSubscriptionManager(
    logger: logger,
    purchase: iap,
  );

  final activePackages = await getActiveSubscriptionPackages(
    subscriptionManager,
  );

  return DefaultIAP(
    purchaser: iap,
    subscriptionManager: subscriptionManager,
    activeSubscription: activePackages?.firstOrNull,
  );
}
