// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/iap/iap.dart';
import '../../../foundation/url_launcher.dart';
import '../../../info/app_info.dart';
import '../../../widgets/widgets.dart';
import '../internal_widgets/subscription_plan_tile.dart';
import '../providers/premium_purchase_provider.dart';

class PremiumPurchaseModal extends ConsumerWidget {
  const PremiumPurchaseModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const modal = _PurchaseInProgressUIBlocker(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BackButtonBlocker(),
          _SubscriptionPlans(),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxHeight < 400
          ? const Stack(
              children: [
                ScrollConfiguration(
                  behavior: MaterialScrollBehavior(),
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: modal,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CloseButton(),
                ),
              ],
            )
          : modal,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                saveIndicator: package
                    .getAnnualToMonthlyDeal(state.availablePackages)
                    ?.savings
                    .toOption()
                    .fold(
                      () => null,
                      (value) => DiscountChip(value: value),
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
            top: 16,
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

class DiscountChip extends StatelessWidget {
  const DiscountChip({
    required this.value,
    super.key,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
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
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
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

class _LegalDisclaimerText extends ConsumerWidget {
  const _LegalDisclaimerText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final appInfo = ref.watch(appInfoProvider);

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
                  launchExternalUrlString(appInfo.termsOfServiceUrl);
                },
              style: TextStyle(
                color: colorScheme.primary,
              ),
            ),
            TextSpan(
              text: ' and ',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            TextSpan(
              text: 'Privacy Policy',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchExternalUrlString(appInfo.privacyPolicyUrl);
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
