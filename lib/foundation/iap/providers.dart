// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'iap_impl.dart';
import 'purchaser.dart';
import 'subscription.dart';

typedef IapFactory = Future<IAP> Function();

final iapFactoryProvider = Provider<IapFactory>(
  (_) => throw UnimplementedError(),
  name: 'iapFactoryProvider',
);

final iapProvider = FutureProvider<IAP>((ref) {
  return ref.watch(iapFactoryProvider)();
});

final subscriptionManagerProvider = FutureProvider<SubscriptionManager>((
  ref,
) async {
  final iap = await ref.watch(iapProvider.future);

  return iap.subscriptionManager;
});

Future<List<Package>?> getActiveSubscriptionPackages(
  SubscriptionManager manager,
) async {
  final packages = await manager.getActiveSubscriptions();

  return packages;
}

Future<IAP> initDummyIap() async {
  final iap = DummyIAP.create();
  await iap.init();

  return iap;
}

final subscriptionPackagesProvider = FutureProvider.autoDispose<List<Package>>((
  ref,
) async {
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
