// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'booru_config_ref.dart';
import 'providers.dart';
import 'route_utils.dart';

class BooruConfigMoreSettingsRedirectCard extends ConsumerWidget {
  const BooruConfigMoreSettingsRedirectCard({
    required this.initialTab,
    super.key,
  });

  const BooruConfigMoreSettingsRedirectCard.imageViewer({
    super.key,
  }) : initialTab = 'viewer';

  const BooruConfigMoreSettingsRedirectCard.download({
    super.key,
  }) : initialTab = 'download';

  const BooruConfigMoreSettingsRedirectCard.search({
    super.key,
  }) : initialTab = 'search';

  const BooruConfigMoreSettingsRedirectCard.appearance({
    super.key,
  }) : initialTab = 'appearance';

  final String initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final hasConfigs = ref.watch(hasBooruConfigsProvider);

    if (!hasConfigs) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need more?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
            ),
            onPressed: () {
              goToUpdateBooruConfigPage(
                context,
                config: config,
                initialTab: initialTab,
              );
            },
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
