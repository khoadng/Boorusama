// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../settings/widgets.dart';
import 'booru_config_ref.dart';
import 'providers.dart';
import 'route_utils.dart';

class BooruConfigMoreSettingsRedirectCard extends ConsumerWidget {
  const BooruConfigMoreSettingsRedirectCard({
    required this.initialTab,
    super.key,
    this.extraActions,
  });

  const BooruConfigMoreSettingsRedirectCard.imageViewer({
    super.key,
    this.extraActions,
  }) : initialTab = 'viewer';

  const BooruConfigMoreSettingsRedirectCard.download({
    super.key,
    this.extraActions,
  }) : initialTab = 'download';

  const BooruConfigMoreSettingsRedirectCard.search({
    super.key,
    this.extraActions,
  }) : initialTab = 'search';

  const BooruConfigMoreSettingsRedirectCard.appearance({
    super.key,
    this.extraActions,
  }) : initialTab = 'appearance';

  final String initialTab;
  final List<RedirectAction>? extraActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final hasConfigs = ref.watch(hasBooruConfigsProvider);

    if (!hasConfigs) {
      return const SizedBox.shrink();
    }

    final actions = extraActions;

    return MoreSettingsRedirectCard(
      actions: [
        RedirectAction(
          label: 'Profile',
          onPressed: () {
            goToUpdateBooruConfigPage(
              context,
              config: config,
              initialTab: initialTab,
            );
          },
        ),
        if (actions != null) ...actions,
      ],
    );
  }
}
