// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../haptics/types.dart';
import '../../../home/types.dart';
import '../generated/settings_index.g.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_anchor.dart';
import '../widgets/settings_page_scaffold.dart';

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
        SettingAnchor(
          id: SettingsIndex.accessibility.reverseProfileScroll.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.accessibility.reverseProfileScroll.title(context),
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
        ),
        SettingAnchor(
          id: SettingsIndex.accessibility.sidebarSwipeArea.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.accessibility.sidebarSwipeArea.title(
                context,
              ),
            ),
            subtitle: Text(
              context
                  .t
                  .settings
                  .accessibility
                  .swipeAreaToOpenSidebarDescription,
              style: TextStyle(
                color: Kurumi.themeOf(context).colorScheme.hintColor,
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
        ),
        SettingAnchor(
          id: SettingsIndex.accessibility.reduceAnimations.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.accessibility.reduceAnimations.title(
                context,
              ),
            ),
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
        ),
        SettingAnchor(
          id: SettingsIndex.accessibility.volumeNavigation.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.accessibility.volumeNavigation.title(
                context,
              ),
            ),
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
        ),
        SettingAnchor(
          id: SettingsIndex.accessibility.hapticFeedback.id,
          child: KurumiSettingsTile(
            title: Text(
              SettingsIndex.accessibility.hapticFeedback.title(context),
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
        ),
      ],
    );
  }
}

List<int> getSwipeAreaPossibleValue() => [for (var i = 5; i <= 100; i += 5) i];
