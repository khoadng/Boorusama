// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'widgets/settings_page_scaffold.dart';

class AccessibilityPage extends ConsumerStatefulWidget {
  const AccessibilityPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends ConsumerState<AccessibilityPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return SettingsPageScaffold(
      hasAppBar: widget.hasAppBar,
      title: const Text('settings.accessibility.accessibility').tr(),
      children: [
        SwitchListTile(
          title: const Text(
                  'settings.accessibility.reverseBooruConfigSelectorScrollDirection')
              .tr(),
          value: settings.reverseBooruConfigSelectorScrollDirection,
          onChanged: (value) => ref.updateSettings(
            settings.copyWith(
              booruConfigSelectorScrollDirection: value
                  ? BooruConfigScrollDirection.reversed
                  : BooruConfigScrollDirection.normal,
            ),
          ),
        ),
        SettingsTile(
          title:
              const Text('settings.accessibility.swipeAreaToOpenSidebar').tr(),
          subtitle: Text(
            'settings.accessibility.swipeAreaToOpenSidebarDescription',
            style: TextStyle(
              color: context.theme.hintColor,
            ),
          ).tr(),
          selectedOption: settings.swipeAreaToOpenSidebarPercentage,
          items: getSwipeAreaPossibleValue(),
          onChanged: (newValue) {
            ref.updateSettings(
                settings.copyWith(swipeAreaToOpenSidebarPercentage: newValue));
          },
          optionBuilder: (value) => Text(
            '$value%',
          ),
        ),
        SwitchListTile(
          title: const Text('Reduce animations'),
          subtitle: const Text(
              'Some features may not work as expected when this is enabled.'),
          value: settings.reduceAnimations,
          onChanged: (value) => ref.updateSettings(
            settings.copyWith(
              reduceAnimations: value,
            ),
          ),
        ),
      ],
    );
  }
}
