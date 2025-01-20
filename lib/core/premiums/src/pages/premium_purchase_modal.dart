// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/iap/iap.dart';
import '../../../widgets/widgets.dart';
import '../internal_widgets/subscription_plan_tile.dart';
import '../providers/premium_purchase_provider.dart';

class PremiumPurchaseModal extends ConsumerWidget {
  const PremiumPurchaseModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DragLine(),
            ],
          ),
          ref.watch(premiumPurchaseProvider).when(
                data: (state) => SubscriptionPlans(
                  purchaseState: state,
                ),
                error: (e, st) => Text('Error: $e'),
                loading: () => const SubscriptionPlansLoading(),
              ),
        ],
      ),
    );
  }
}

class SubscriptionPlans extends ConsumerWidget {
  const SubscriptionPlans({
    required this.purchaseState,
    super.key,
  });

  final PremiumPurchaseState purchaseState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(premiumPurchaseProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select your plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...purchaseState.availablePackages.map(
          (package) => SubscriptionPlanTile(
            selected: package == purchaseState.selectedPackage,
            package: package,
            saveIndicator: package.bestValue?.savings.toOption().fold(
                  () => null,
                  (value) => IgnorePointer(
                    child: RawCompactChip(
                      label: Text(
                        '-${(value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: colorScheme.primaryContainer,
                    ),
                  ),
                ),
            onTap: () => notifier.selectPackage(package),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
            ),
            onPressed: ref.watch(packagePurchaseProvider).maybeWhen(
                  orElse: () => () async {
                    final navigator = Navigator.of(context);
                    final success = await notifier.purchase();

                    if (success) {
                      navigator.pop();
                    }
                  },
                  loading: () => null,
                ),
            child: ref.watch(packagePurchaseProvider).maybeWhen(
                  orElse: () => const Text('Subscribe'),
                  loading: () => SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
          ),
        ),
        const LegalDisclaimerText(),
        const SizedBox(height: 36),
      ],
    );
  }
}

class LegalDisclaimerText extends StatelessWidget {
  const LegalDisclaimerText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 16,
      ),
      child: RichText(
        text: TextSpan(
          text: 'By subscribing, you agree to our ',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
          children: [
            TextSpan(
              text: 'Terms of Service',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  //FIXME: open terms of service
                },
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
            const TextSpan(
              text:
                  '. Subscription automatically renews until canceled. You can cancel anytime up to 24 hours before your current period ends.',
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPlansLoading extends StatelessWidget {
  const SubscriptionPlansLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 32,
            bottom: 16,
          ),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
