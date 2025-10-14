// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/boot/providers.dart';
import '../../../../foundation/iap/iap.dart';
import '../../types.dart';

const _premiumMode = String.fromEnvironment('PREMIUM_MODE');
final kPremiumMode = parsePremiumMode(_premiumMode);
final kForcePremium = parsePremiumMode(_premiumMode) == PremiumMode.premium;

final hasPremiumProvider = Provider<bool>((ref) {
  final isFoss = ref.watch(isFossBuildProvider);
  if (isFoss) return false;

  if (kPremiumMode == PremiumMode.hidden) return false;
  if (kPremiumMode == PremiumMode.premium) return true;

  final package = ref.watch(subscriptionNotifierProvider);

  return package.valueOrNull != null;
});

final premiumManagementURLProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final isFoss = ref.watch(isFossBuildProvider);
  if (isFoss) return null;

  if (kPremiumMode == PremiumMode.hidden) return Future.value();
  if (kPremiumMode == PremiumMode.premium) return Future.value();

  return (await ref.watch(subscriptionManagerProvider.future)).managementURL;
});

final showPremiumFeatsProvider = Provider<bool>((ref) {
  final isFoss = ref.watch(isFossBuildProvider);
  final premiumEnabled = parsePremiumMode(_premiumMode) != PremiumMode.hidden;

  return !isFoss && premiumEnabled;
});
