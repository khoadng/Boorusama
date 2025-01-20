// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/iap/iap.dart';
import '../../../foundation/toast.dart';
import '../internal_widgets/benefit_card.dart';
import '../types/premium.dart';
import '../types/strings.dart';
import 'premium_purchase_modal.dart';
import 'premium_thanks_dialog.dart';

class PremiumOffersPage extends ConsumerWidget {
  const PremiumOffersPage({
    required this.canGoBack,
    super.key,
  });

  final bool canGoBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      packagePurchaseProvider,
      (prev, cur) {
        cur.when(
          data: (success) {
            if (success == true) {
              showDialog(
                context: context,
                builder: (context) => const Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: PremiumThanksDialog(),
                ),
              );
            } else if (success == false) {
              _showFailedPurchase(context);
            }
          },
          loading: () {},
          error: (_, __) {
            _showFailedPurchase(context);
          },
        );
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 36),
                        _buildTitle(),
                        const SizedBox(height: 12),
                        _buildBenefits(ref),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRestoreButton(context, ref),
                    _buildPurchaseButton(ref, context),
                  ],
                ),
              ],
            ),
            if (canGoBack)
              Positioned(
                top: 4,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(WidgetRef ref, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 12,
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
        ),
        onPressed: ref.watch(packagePurchaseProvider).when(
              data: (_) {
                return () => _showPlans(context, ref);
              },
              loading: () => null,
              error: (_, __) {
                return () => _showPlans(context, ref);
              },
            ),
        child: ref.watch(packagePurchaseProvider).maybeWhen(
              orElse: () => const Text('Get Plus'),
              loading: () => SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: ref.watch(packagePurchaseProvider).maybeWhen(
              loading: () => null,
              orElse: () {
                return () => restore(ref, context);
              },
            ),
        child: const Text('Restore subscription'),
      ),
    );
  }

  Widget _buildBenefits(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: defaultBenefits
          .map(
            (benefit) => BenefitCard(
              title: benefit.title,
              description: benefit.description,
            ),
          )
          .toList(),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 36,
              height: 36,
              isAntiAlias: true,
              filterQuality: FilterQuality.none,
            ),
          ),
          const Expanded(
            child: Text(
              kPremiumBrandNameFull,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 26,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailedPurchase(BuildContext context) {
    return showSimpleSnackBar(
      context: context,
      content: const Text(
        'There was a problem purchasing your subscription. Please try again later.',
      ),
      duration: const Duration(seconds: 2),
    );
  }

  void restore(WidgetRef ref, BuildContext context) {
    ref.read(subscriptionNotifierProvider.notifier).restoreSubscription().then(
      (res) {
        if (context.mounted) {
          if (res) {
            showSimpleSnackBar(
              context: context,
              content: const Text('Subscription restored!'),
              duration: const Duration(seconds: 2),
            );
          } else {
            _showFailedRestore(context);
          }
        }
      },
    ).catchError(
      (e, st) {
        if (context.mounted) {
          _showFailedRestore(context);
        }
      },
    );
  }

  void _showFailedRestore(BuildContext context) {
    showSimpleSnackBar(
      context: context,
      content: const Text(
        'There was a problem restoring your subscription. Please try again later.',
      ),
      duration: const Duration(seconds: 2),
    );
  }

  Future<dynamic> _showPlans(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      routeSettings: const RouteSettings(name: 'select_subscription_plan'),
      builder: (modalContext) {
        return const PremiumPurchaseModal();
      },
    );
  }
}
