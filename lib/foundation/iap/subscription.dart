// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'iap.dart';

abstract class SubscriptionManager {
  Future<bool> hasActiveSubscription(String id);

  Future<String?> get managementURL;

  Future<List<Package>> getActiveSubscriptions();
}

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, Package?>(
        () => throw UnimplementedError());

final packagePurchaseProvider =
    AsyncNotifierProvider.autoDispose<PackagePurchaseNotifier, bool?>(
        PackagePurchaseNotifier.new);

class PackagePurchaseNotifier extends AutoDisposeAsyncNotifier<bool?> {
  @override
  Future<bool?> build() {
    return Future.value(null);
  }

  static const _kServiceName = 'Purchaser';

  Future<void> startPurchase(Package package) async {
    final logger = ref.read(loggerProvider);

    try {
      state = const AsyncLoading();

      logger.logI(
          _kServiceName, 'Starting purchase for package: ${package.id}...');

      final notifier = ref.read(subscriptionNotifierProvider.notifier);

      await notifier.purchasePackage(package);

      logger.logI(
          _kServiceName, 'Purchase successful for package: ${package.id}');

      state = const AsyncData(true);
    } catch (e, st) {
      logger.logE(
          _kServiceName, 'Failed to purchase package: ${package.id}, $e');

      state = AsyncError(e, st);
    }
  }
}

class SubscriptionNotifier extends Notifier<Package?> {
  SubscriptionNotifier({
    required this.initialPackage,
    required this.iap,
    required this.manager,
  });

  final Package? initialPackage;
  final InAppPurchase iap;
  final SubscriptionManager manager;

  @override
  Package? build() {
    return initialPackage;
  }

  Future<void> purchasePackage(Package package) async {
    try {
      final success = await iap.purchasePackage(package);
      if (success) {
        state = package;
      }
    } on Exception catch (e) {
      final error = iap.describePurchaseError(e);

      if (error == null) {
        rethrow;
      } else {
        throw Exception(error);
      }
    }
  }

  Future<void> debugCancelSubscription() async {
    state = null;
  }

  Future<bool> restoreSubscription() async {
    final logger = ref.read(loggerProvider);

    logger.logI('Subscription', 'Restoring subscription...');

    final res = await iap.restorePurchases();

    logger.logI('Subscription', 'Restore result: $res');

    final activePackages = await getActiveSubscriptionPackages(manager);
    final activePackage = activePackages?.firstOrNull;

    logger.logI('Subscription', 'Active package: ${activePackage?.id}');

    if (activePackage != null) {
      state = activePackage;
    }

    final success = res == true && activePackage != null;

    logger.logI('Subscription', 'Restore success: $success');

    return success;
  }
}