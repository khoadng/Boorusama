// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../loggers.dart';
import '../platform.dart';
import '../revenuecat/revenuecat.dart';
import 'iap_impl.dart';
import 'purchaser.dart';
import 'subscription.dart';

final iapProvider = FutureProvider<IAP>((ref) async {
  final IAP iap;
  final logger = ref.watch(loggerProvider);

  if (isMobilePlatform()) {
    iap = (await initRevenuecatIap(logger)) ?? await _initDummyIap();
  } else {
    iap = await _initDummyIap();
  }

  return iap;
});

final subscriptionManagerProvider =
    FutureProvider<SubscriptionManager>((ref) async {
  final iap = await ref.watch(iapProvider.future);

  return iap.subscriptionManager;
});

Future<List<Package>?> getActiveSubscriptionPackages(
  SubscriptionManager manager,
) async {
  final packages = await manager.getActiveSubscriptions();

  return packages;
}

Future<IAP> _initDummyIap() async {
  final iap = DummyIAP.create();
  await iap.init();

  return iap;
}

final subscriptionPackagesProvider =
    FutureProvider.autoDispose<List<Package>>((ref) async {
  final iap = await ref.watch(iapProvider.future);
  final availablePackages = await iap.purchaser.getAvailablePackages();

  // sort annual packages first
  final packages = availablePackages.toList()
    ..sort((a, b) {
      if (a.type == PackageType.annual) {
        return -1;
      }

      return 1;
    });

  return packages;
});
