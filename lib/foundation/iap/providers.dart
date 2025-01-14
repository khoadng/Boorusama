// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/foundation/loggers.dart';
import 'dummy.dart';
import 'in_app_purchase.dart';
import 'subscription.dart';

final iapProvider = Provider<InAppPurchase>((ref) {
  throw UnimplementedError();
});

final subscriptionManagerProvider = Provider<SubscriptionManager>((ref) {
  throw UnimplementedError();
});

Future<List<Package>?> getActiveSubscriptionPackages(
  SubscriptionManager manager,
) async {
  final packages = await manager.getActiveSubscriptions();

  return packages;
}

const _kPackages = <Package>[
  Package(
    id: 'annual_subscription',
    product: ProductDetails(
      id: 'annual_subscription',
      title: '1 year',
      description: '',
      price: r'$19.99',
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
      price: r'$2.99',
      rawPrice: 2.99,
      currencyCode: 'USD',
    ),
    type: PackageType.monthly,
  ),
];

// const _kVNDPackages = <Package>[
//   Package(
//     id: 'annual_subscription',
//     product: ProductDetails(
//       id: 'annual_subscription',
//       title: '1 year',
//       description: '',
//       price: '₫260000',
//       rawPrice: 260000,
//       currencyCode: 'VND',
//     ),
//     type: PackageType.annual,
//   ),
//   Package(
//     id: 'monthly_subscription',
//     product: ProductDetails(
//       id: 'monthly_subscription',
//       title: '1 month',
//       description: '',
//       price: '₫45000',
//       rawPrice: 45000,
//       currencyCode: 'VND',
//     ),
//     type: PackageType.monthly,
//   ),
// ];

Future<(InAppPurchase, SubscriptionManager, Package?)> initIap(
  Logger logger,
) async {
  final iap = DummyInAppPurchase(
    packages: _kPackages,
  );

  final subscriptionManager = DummySubscriptionManager(
    iap: iap,
  );

  final activePackages =
      await getActiveSubscriptionPackages(subscriptionManager);

  return (iap, subscriptionManager, activePackages?.firstOrNull);
}

final subscriptionPackagesProvider =
    FutureProvider.autoDispose<List<Package>>((ref) async {
  final iap = ref.watch(iapProvider);
  return iap.getAvailablePackages();
});
