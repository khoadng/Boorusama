// Project imports:
import 'dummy.dart';
import 'providers.dart';
import 'purchaser.dart';
import 'subscription.dart';

class DefaultIAP implements IAP {
  DefaultIAP({
    required this.purchaser,
    required this.subscriptionManager,
    this.activeSubscription,
  });

  @override
  final Purchaser purchaser;

  @override
  final SubscriptionManager subscriptionManager;

  @override
  final Package? activeSubscription;
}

class DummyIAP implements IAP {
  DummyIAP._({
    required this.purchaser,
    required this.subscriptionManager,
  });

  factory DummyIAP.create() {
    final iap = DummyPurchaser(
      packages: _kPackages,
    );

    final subscriptionManager = DummySubscriptionManager(
      iap: iap,
    );

    return DummyIAP._(
      purchaser: iap,
      subscriptionManager: subscriptionManager,
    );
  }

  Future<void> init() async {
    final activePackages =
        await getActiveSubscriptionPackages(subscriptionManager);

    if (activePackages != null && activePackages.isNotEmpty) {
      _activeSubscription = activePackages.first;
    }
  }

  Package? _activeSubscription;

  @override
  final Purchaser purchaser;

  @override
  final SubscriptionManager subscriptionManager;

  @override
  Package? get activeSubscription => _activeSubscription;

  static const _kPackages = <Package>[
    Package(
      id: 'annual_subscription',
      product: ProductDetails(
        id: 'annual_subscription',
        title: '1 year',
        description: '',
        price: r'$39.99',
        rawPrice: 39.99,
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
        price: r'$4.99',
        rawPrice: 4.99,
        currencyCode: 'USD',
      ),
      type: PackageType.monthly,
    ),
  ];
}
