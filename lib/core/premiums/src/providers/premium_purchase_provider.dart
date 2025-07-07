// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/iap/iap.dart';

final premiumPurchaseProvider =
    AsyncNotifierProvider.autoDispose<
      PremiumPurchaseNotifier,
      PremiumPurchaseState
    >(PremiumPurchaseNotifier.new);

class PremiumPurchaseNotifier
    extends AutoDisposeAsyncNotifier<PremiumPurchaseState> {
  @override
  FutureOr<PremiumPurchaseState> build() async {
    final packages = await ref.watch(subscriptionPackagesProvider.future);

    return PremiumPurchaseState(
      selectedPackage: packages.firstOrNull,
      availablePackages: packages,
    );
  }

  void selectPackage(Package package) {
    final s = state.value;

    if (s == null) return;

    state = AsyncValue.data(
      s.copyWith(
        selectedPackage: package,
      ),
    );
  }

  Future<bool> purchase() async {
    final selected = state.value?.selectedPackage;

    if (selected != null) {
      return ref.read(packagePurchaseProvider.notifier).startPurchase(selected);
    }

    return false;
  }
}

class PremiumPurchaseState extends Equatable {
  const PremiumPurchaseState({
    required this.selectedPackage,
    required this.availablePackages,
  });

  final Package? selectedPackage;
  final List<Package> availablePackages;

  PremiumPurchaseState copyWith({
    Package? selectedPackage,
    List<Package>? availablePackages,
  }) {
    return PremiumPurchaseState(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      availablePackages: availablePackages ?? this.availablePackages,
    );
  }

  @override
  List<Object?> get props => [selectedPackage, availablePackages];
}
