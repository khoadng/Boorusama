// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/iap/subscription.dart';
import 'premiums.dart';

const kPremiumEnabled = true;

final hasPremiumProvider = Provider<bool>((ref) {
  if (!kPremiumEnabled) return true;

  final package = ref.watch(subscriptionNotifierProvider);

  return package != null;
});

final premiumBenefitProvider = FutureProvider<List<Benefit>>((ref) {
  return Future.value(defaultBenefits);
});
