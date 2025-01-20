// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/iap/iap.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/toast.dart';
import '../../../foundation/url_launcher.dart';
import '../../premiums.dart';
import '../providers/premium_providers.dart';

class PremiumManagePage extends ConsumerWidget {
  const PremiumManagePage({
    required this.package,
    super.key,
  });

  final Package package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = ref.watch(loggerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(kPremiumBrandNameFull),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SingleChildScrollView(
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
                          .withValues(alpha: 0.6),
                    ),
              ),
              Text('You are subscribed to ${package.product.title}'),
              ref.watch(premiumManagementURLProvider).when(
                    data: (url) => kDebugMode
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(subscriptionNotifierProvider.notifier)
                                    .debugCancelSubscription();
                              },
                              child: const Text('Cancel Subscription (debug)'),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () {
                                if (url == null) {
                                  logger.logW(
                                    'Subscription',
                                    'Management URL is null. Cannot open.',
                                  );

                                  showErrorToast(
                                    context,
                                    'Failed to open subscription management',
                                  );

                                  return;
                                }

                                // open management URL
                                logger.logI(
                                  'Subscription',
                                  'Opening management URL: $url',
                                );
                                launchExternalUrlString(url);
                              },
                              child: const Text('Manage Subscription'),
                            ),
                          ),
                    error: (e, st) => const SizedBox.shrink(),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
