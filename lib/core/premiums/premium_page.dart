// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/iap/iap.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'premiums.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({
    super.key,
    this.canGoBack = true,
  });

  final bool canGoBack;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  @override
  Widget build(BuildContext context) {
    final package = ref.watch(subscriptionNotifierProvider);

    if (package != null) {
      return _buildManage(package);
    }

    return PremiumOffersPage(
      canGoBack: widget.canGoBack,
    );
  }

  Widget _buildManage(Package package) {
    final susbscriptionManager = ref.read(subscriptionManagerProvider);
    final managementURL = susbscriptionManager.managementURL;
    final logger = ref.read(loggerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(kPremiumBrandNameFull),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your subscriptions'.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            Text('You are subscribed to ${package.product.title}'),
            if (managementURL != null)
              Container(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    // open management URL
                    logger.logI('Subscription',
                        'Opening management URL: $managementURL');
                    launchExternalUrlString(managementURL);
                  },
                  child: const Text('Cancel'),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(subscriptionNotifierProvider.notifier)
                        .cancelSubscription();
                  },
                  child: const Text('Cancel Subscription (debug)'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PremiumOffersPage extends ConsumerWidget {
  const PremiumOffersPage({
    super.key,
    required this.canGoBack,
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
                builder: (context) => Dialog(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const PremiumThanksDialog(),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Container(
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
                      Expanded(
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
                ),
                const SizedBox(height: 16),
                ref.watch(premiumBenefitProvider).when(
                      data: (benefits) => SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: benefits
                              .map(
                                (benefit) => BenefitCard(
                                  title: benefit.title,
                                  description: benefit.description,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      error: (e, st) => Text('Error: ${e.toString()}'),
                      loading: () => const CircularProgressIndicator(),
                    ),
                const Spacer(),
                TextButton(
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
                Container(
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
      builder: (modalContext) {
        return SubscriptionPlanSelectModal(
          onPurchase: (package) async {
            Navigator.of(modalContext).pop();

            await ref
                .read(packagePurchaseProvider.notifier)
                .startPurchase(package);
          },
        );
      },
    );
  }
}

class SubscriptionPlanSelectModal extends ConsumerWidget {
  const SubscriptionPlanSelectModal({
    super.key,
    required this.onPurchase,
  });

  final void Function(Package) onPurchase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          ref.watch(subscriptionPackagesProvider).when(
                data: (products) => SubscriptionPlans(
                  products: products,
                  onPurchase: onPurchase,
                ),
                error: (e, st) => Text('Error: $e'),
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class SubscriptionPlans extends ConsumerStatefulWidget {
  const SubscriptionPlans({
    super.key,
    required this.products,
    required this.onPurchase,
  });

  final List<Package> products;
  final void Function(Package) onPurchase;

  @override
  ConsumerState<SubscriptionPlans> createState() => _SubscriptionPlansState();
}

class _SubscriptionPlansState extends ConsumerState<SubscriptionPlans> {
  late var selected = widget.products.firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Select your plan'),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.products.map(
            (product) => SubscriptionPlanTile(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              selected: product == selected,
              package: product,
              saveIndicator: product.bestValue?.savings.toOption().fold(
                    () => null,
                    (value) => IgnorePointer(
                      child: CompactChip(
                        label: '${(value * 100).toStringAsFixed(0)}% off',
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              onTap: () => setState(
                () {
                  selected = product;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
              ),
              onPressed: ref.watch(packagePurchaseProvider).maybeWhen(
                    orElse: () {
                      return () => _purchase();
                    },
                    loading: () => null,
                  ),
              child: ref.watch(packagePurchaseProvider).maybeWhen(
                    orElse: () => const Text('Subscribe'),
                    loading: () => SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
            ),
          ),
          Center(
            child: Container(
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          //FIXME: open terms of service
                        },
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Subscription automatically renews until canceled. You can cancel anytime up to 24 hours before your current period ends.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  void _purchase() {
    if (selected != null) {
      widget.onPurchase(selected!);
    }
  }
}

class SubscriptionPlanTile extends StatelessWidget {
  const SubscriptionPlanTile({
    super.key,
    required this.package,
    this.selected = false,
    this.onTap,
    this.saveIndicator,
    this.backgroundColor,
  });

  final Package package;
  final bool selected;
  final void Function()? onTap;
  final Widget? saveIndicator;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 12,
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 60,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(switch (package.type) {
                      null => '???',
                      PackageType.monthly => 'Monthly',
                      PackageType.annual => 'Yearly',
                    }),
                    if (saveIndicator != null) ...[
                      const SizedBox(width: 8),
                      saveIndicator!,
                    ]
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: package.product.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: ' /${package.typeDurationString}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BenefitCard extends StatelessWidget {
  const BenefitCard({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
