// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../theme.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../types/types.dart';
import '../widgets/settings_page_scaffold.dart';
import '../widgets/settings_tile.dart';

class AccessibilityPage extends ConsumerStatefulWidget {
  const AccessibilityPage({
    super.key,
  });

  @override
  ConsumerState<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends ConsumerState<AccessibilityPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    return SettingsPageScaffold(
      title: const Text('settings.accessibility.accessibility').tr(),
      children: [
        SwitchListTile(
          title: const Text(
            'settings.accessibility.reverseBooruConfigSelectorScrollDirection',
          ).tr(),
          value: settings.reverseBooruConfigSelectorScrollDirection,
          onChanged: (value) => notifer.updateSettings(
            settings.copyWith(
              booruConfigSelectorScrollDirection: value
                  ? BooruConfigScrollDirection.reversed
                  : BooruConfigScrollDirection.normal,
            ),
          ),
        ),
        SettingsTile(
          title: const Text(
            'settings.accessibility.swipeAreaToOpenSidebar',
          ).tr(),
          subtitle: Text(
            'settings.accessibility.swipeAreaToOpenSidebarDescription',
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ).tr(),
          selectedOption: settings.swipeAreaToOpenSidebarPercentage,
          items: getSwipeAreaPossibleValue(),
          onChanged: (newValue) {
            notifer.updateSettings(
              settings.copyWith(swipeAreaToOpenSidebarPercentage: newValue),
            );
          },
          optionBuilder: (value) => Text(
            '$value%',
          ),
        ),
        SwitchListTile(
          title: const Text('Reduce animations'),
          subtitle: const Text(
            'Some features may not work as expected when this is enabled.',
          ),
          value: settings.reduceAnimations,
          onChanged: (value) => notifer.updateSettings(
            settings.copyWith(
              reduceAnimations: value,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Use volume keys for navigation'),
          subtitle: const Text(
            'Navigate between posts using the volume keys when in image viewer.',
          ).tr(),
          value: settings.volumeKeyViewerNavigation,
          onChanged: (value) => notifer.updateSettings(
            settings.copyWith(
              volumeKeyViewerNavigation: value,
            ),
          ),
        ),
      ],
    );
  }
}

List<int> getSwipeAreaPossibleValue() => [for (var i = 5; i <= 100; i += 5) i];
