// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/iap/iap.dart';
import '../../premiums.dart';

const _premiumMode = String.fromEnvironment('PREMIUM_MODE');
final kPremiumMode = parsePremiumMode(_premiumMode);
final kPremiumEnabled = parsePremiumMode(_premiumMode) != PremiumMode.hidden;

final hasPremiumProvider = Provider<bool>((ref) {
  if (kPremiumMode == PremiumMode.hidden) return false;
  if (kPremiumMode == PremiumMode.premium) return true;

  final package = ref.watch(subscriptionNotifierProvider);

  return package != null;
});

final premiumManagementURLProvider = FutureProvider.autoDispose<String?>((ref) {
  if (kPremiumMode == PremiumMode.hidden) return Future.value(null);
  if (kPremiumMode == PremiumMode.premium) return Future.value(null);

  return ref.watch(subscriptionManagerProvider).managementURL;
});
