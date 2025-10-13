// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../haptics/types.dart';
import '../../../home/types.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
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
      title: Text(context.t.settings.accessibility.accessibility),
      children: [
        BooruSwitchListTile(
          title: Text(
            context
                .t
                .settings
                .accessibility
                .reverseBooruConfigSelectorScrollDirection,
          ),
          value: settings.booruConfigSelectorScrollDirection.isReversed,
          onChanged: (value) => notifer.updateSettings(
            settings.copyWith(
              booruConfigSelectorScrollDirection: value
                  ? BooruConfigScrollDirection.reversed
                  : BooruConfigScrollDirection.normal,
            ),
          ),
        ),
        SettingsTile(
          title: Text(context.t.settings.accessibility.swipeAreaToOpenSidebar),
          subtitle: Text(
            context.t.settings.accessibility.swipeAreaToOpenSidebarDescription,
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
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
        BooruSwitchListTile(
          title: Text(context.t.settings.accessibility.reduce_animations),
          subtitle: Text(
            context.t.settings.accessibility.reduce_animations_description,
          ),
          value: settings.reduceAnimations,
          onChanged: (value) => notifer.updateSettings(
            settings.copyWith(
              reduceAnimations: value,
            ),
          ),
        ),
        BooruSwitchListTile(
          title: Text(context.t.settings.accessibility.volume_navigation),
          subtitle: Text(
            context.t.settings.accessibility.volume_navigation_description,
          ),
          value: settings.volumeKeyViewerNavigation,
          onChanged: (value) => notifer.updateSettings(
            settings.copyWith(
              volumeKeyViewerNavigation: value,
            ),
          ),
        ),
        SettingsTile(
          title: Text(
            context.t.settings.accessibility.haptic_feedback.haptic_feedback,
          ),
          selectedOption: settings.hapticFeedbackLevel,
          items: HapticFeedbackLevel.values,
          onChanged: (newValue) {
            notifer.updateSettings(
              settings.copyWith(hapticFeedbackLevel: newValue),
            );
          },
          optionBuilder: (value) => Text(
            value.localize(context),
          ),
        ),
      ],
    );
  }
}

List<int> getSwipeAreaPossibleValue() => [for (var i = 5; i <= 100; i += 5) i];
