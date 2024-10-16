// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/iap/iap.dart';

final iapProvider = Provider<InAppPurchase>((ref) {
  throw UnimplementedError();
});

final subscriptionManagerProvider = Provider<SubscriptionManager>((ref) {
  throw UnimplementedError();
});

Future<Package?> getActiveSubscriptionPackage(
  SubscriptionManager manager,
  InAppPurchase iap,
) async {
  final packages = await iap.getAvailablePackages();

  for (final package in packages) {
    if (await manager.hasActiveSubscription(package.id)) {
      return package;
    }
  }

  return null;
}

const _kPackages = <Package>[
  Package(
    id: 'annual_subscription',
    product: ProductDetails(
      id: 'annual_subscription',
      title: '1 year',
      description: '',
      price: '\$19.99',
      rawPrice: 19.99,
      currencyCode: 'USD',
    ),
    type: PackageType.annual,
  ),
  Package(
    id: 'monthly_subscription',
    product: ProductDetails(
      id: 'monthly_subscription',
      title: '1 month',
      description: '',
      price: '\$1.99',
      rawPrice: 1.99,
      currencyCode: 'USD',
    ),
    type: PackageType.monthly,
  ),
];

const _kVNDPackages = <Package>[
  Package(
    id: 'annual_subscription',
    product: ProductDetails(
      id: 'annual_subscription',
      title: '1 year',
      description: '',
      price: '₫260000',
      rawPrice: 260000,
      currencyCode: 'VND',
    ),
    type: PackageType.annual,
  ),
  Package(
    id: 'monthly_subscription',
    product: ProductDetails(
      id: 'monthly_subscription',
      title: '1 month',
      description: '',
      price: '₫45000',
      rawPrice: 45000,
      currencyCode: 'VND',
    ),
    type: PackageType.monthly,
  ),
];

Future<(InAppPurchase, SubscriptionManager, Package?)> initIap() async {
  final iap = DummyInAppPurchase(
    packages: _kPackages,
    restorePackage: _kPackages.first,
  );

  final subscriptionManager = DummySubscriptionManager(
    iap: iap,
  );

  final activePackage =
      await getActiveSubscriptionPackage(subscriptionManager, iap);

  return (iap, subscriptionManager, activePackage);
}

final subscriptionPackagesProvider =
    FutureProvider.autoDispose<List<Package>>((ref) async {
  final iap = ref.watch(iapProvider);
  return iap.getAvailablePackages();
});
