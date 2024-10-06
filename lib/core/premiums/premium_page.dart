// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import 'package:boorusama/foundation/iap/iap.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'premiums.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  final pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final package = ref.watch(subscriptionNotifierProvider);

    if (package != null) {
      return _buildManage(package);
    }

    return _buildOffers();
  }

  Widget _buildManage(Package package) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscription'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Manage your subscription'),
            Text('You are subscribed to ${package.product.title}'),
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

  Widget _buildOffers() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                  ),
                  child: ref.watch(premiumBenefitProvider).when(
                        data: (benefits) => PageView.builder(
                          controller: pageController,
                          itemCount: benefits.length,
                          itemBuilder: (context, index) {
                            final benefit = benefits[index];
                            return BenefitCard(
                              title: benefit.title,
                              description: benefit.description,
                            );
                          },
                        ),
                        error: (e, st) => Text('Error: $e'),
                        loading: () => const CircularProgressIndicator(),
                      ),
                ),
                ref.watch(premiumBenefitProvider).when(
                      data: (benefits) => SmoothPageIndicator(
                        controller: pageController,
                        count: benefits.length,
                        effect: WormEffect(
                          dotWidth: 8,
                          dotHeight: 8,
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.25),
                        ),
                      ),
                      error: (e, st) => const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                    ),
                const Spacer(),
                const Text('Select your plan'),
                const SizedBox(height: 8),
                ref.watch(subscriptionPackagesProvider).when(
                      data: (products) => SubscriptionPlans(
                        products: products,
                        onPurchase: (package) async {
                          ref
                              .read(packagePurchaseProvider.notifier)
                              .startPurchase(package);
                        },
                      ),
                      error: (e, st) => Text('Error: $e'),
                      loading: () => const CircularProgressIndicator(),
                    ),
              ],
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.products.map(
          (product) => SubscriptionPlanTile(
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
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Subscription auto renews for ${selected?.product.price ?? ''}/${selected?.typeDurationString} until canceled',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
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
                  data: (state) => () {
                    if (selected != null) {
                      widget.onPurchase(selected!);
                    }
                  },
                  orElse: () => null,
                ),
            child: ref.watch(packagePurchaseProvider).when(
                  data: (state) => const Text('Get Plus'),
                  error: (e, st) => Text('Error: $e'),
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
        const SizedBox(height: 16),
      ],
    );
  }
}

class SubscriptionPlanTile extends StatelessWidget {
  const SubscriptionPlanTile({
    super.key,
    required this.package,
    this.selected = false,
    this.onTap,
    this.saveIndicator,
  });

  final Package package;
  final bool selected;
  final void Function()? onTap;
  final Widget? saveIndicator;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                    Text(package.product.title),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}
