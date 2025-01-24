// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/iap/iap.dart';
import '../../../widgets/widgets.dart';
import '../internal_widgets/subscription_plan_tile.dart';
import '../providers/premium_purchase_provider.dart';

class PremiumPurchaseModal extends ConsumerWidget {
  const PremiumPurchaseModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _PurchaseInProgressUIBlocker(
      child: _PremiumModalContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BackButtonBlocker(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DragLine(),
              ],
            ),
            _SubscriptionPlans(),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionPlans extends ConsumerWidget {
  const _SubscriptionPlans();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(premiumPurchaseProvider).when(
          data: (state) => _buildPlans(context, state),
          error: (e, st) => SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    e.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => _buildLoading(),
        );
  }

  Widget _buildPlans(BuildContext context, PremiumPurchaseState state) {
    final colorScheme = Theme.of(context).colorScheme;

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
        ...state.availablePackages.map(
          (package) => Consumer(
            builder: (context, ref, child) {
              final notifier = ref.watch(premiumPurchaseProvider.notifier);

              return SubscriptionPlanTile(
                selected: package == state.selectedPackage,
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
              );
            },
          ),
        ),
        const _PurchaseButton(),
        const _LegalDisclaimerText(),
      ],
    );
  }

  Widget _buildLoading() {
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

class _PurchaseButton extends ConsumerWidget {
  const _PurchaseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(premiumPurchaseProvider.notifier);
    final navigator = Navigator.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
        ),
        onPressed: ref.watch(packagePurchaseProvider).maybeWhen(
              orElse: () => () async {
                await notifier.purchase();

                navigator.pop();
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
    );
  }
}

class _PremiumModalContainer extends StatelessWidget {
  const _PremiumModalContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BackButtonBlocker extends ConsumerWidget {
  const _BackButtonBlocker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(packagePurchaseProvider).maybeWhen(
          orElse: () => const SizedBox.shrink(),
          loading: () => const PopScope(
            canPop: false,
            child: SizedBox.shrink(),
          ),
        );
  }
}

class _LegalDisclaimerText extends StatelessWidget {
  const _LegalDisclaimerText();

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

class _PurchaseInProgressUIBlocker extends ConsumerWidget {
  const _PurchaseInProgressUIBlocker({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AbsorbPointer(
      absorbing: ref.watch(packagePurchaseProvider).maybeWhen(
            loading: () => true,
            orElse: () => false,
          ),
      child: child,
    );
  }
}
