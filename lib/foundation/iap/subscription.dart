// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../loggers.dart';
import 'iap.dart';

abstract class SubscriptionManager {
  Future<bool> hasActiveSubscription(String id);

  Future<String?> get managementURL;

  Future<List<Package>> getActiveSubscriptions();
}

final subscriptionNotifierProvider =
    AsyncNotifierProvider<SubscriptionNotifier, Package?>(
      SubscriptionNotifier.new,
    );

final packagePurchaseProvider =
    AsyncNotifierProvider.autoDispose<PackagePurchaseNotifier, bool?>(
      PackagePurchaseNotifier.new,
    );

class PackagePurchaseNotifier extends AutoDisposeAsyncNotifier<bool?> {
  @override
  Future<bool?> build() {
    return Future.value(null);
  }

  static const _kServiceName = 'Purchaser';

  Future<bool> startPurchase(Package package) async {
    final logger = ref.read(loggerProvider);

    try {
      state = const AsyncLoading();

      logger.info(
        _kServiceName,
        'Starting purchase for package: ${package.id}...',
      );

      final notifier = ref.read(subscriptionNotifierProvider.notifier);

      final success = await notifier.purchasePackage(package);

      logger.info(
        _kServiceName,
        'Purchase result for package: ${package.id}, $success',
      );

      state = AsyncData(success);

      return success;
    } on Exception catch (e, st) {
      logger.error(
        _kServiceName,
        'Failed to purchase package: ${package.id}, $e',
      );

      state = AsyncError(e, st);

      return false;
    }
  }
}

class SubscriptionNotifier extends AsyncNotifier<Package?> {
  @override
  FutureOr<Package?> build() async {
    final iap = await ref.watch(iapProvider.future);

    return iap.activeSubscription;
  }

  Future<bool> purchasePackage(Package package) async {
    final iap = await ref.watch(iapProvider.future);
    try {
      final success = await iap.purchaser.purchasePackage(package);
      if (success) {
        state = AsyncData(package);
      }

      return success;
    } on Exception catch (e, st) {
      final error = iap.purchaser.describePurchaseError(e);

      if (error == null) {
        Error.throwWithStackTrace(e, st);
      } else {
        Error.throwWithStackTrace(Exception(error), st);
      }
    }
  }

  Future<void> debugCancelSubscription() async {
    state = const AsyncValue.data(null);
  }

  Future<bool> restoreSubscription() async {
    final logger = ref.read(loggerProvider)
      ..info('Subscription', 'Restoring subscription...');

    final iap = await ref.watch(iapProvider.future);
    final manager = iap.subscriptionManager;

    final res = await iap.purchaser.restorePurchases();

    logger.info('Subscription', 'Restore result: $res');

    final activePackages = await getActiveSubscriptionPackages(manager);
    final activePackage = activePackages?.firstOrNull;

    logger.info('Subscription', 'Active package: ${activePackage?.id}');

    if (activePackage != null) {
      state = AsyncData(activePackage);
    }

    final success = res == true && activePackage != null;

    logger.info('Subscription', 'Restore success: $success');

    return success;
  }
}
